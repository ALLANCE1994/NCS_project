import subprocess
import os
import git
import nbformat
import h5py
import time
import yaml

# 加载配置
with open("agent_config.yaml", "r") as f:
    config = yaml.safe_load(f)

def run_vivado_tcl(tcl_script):
    """执行Vivado TCL脚本并返回标准输出和标准错误"""
    tcl_file = "temp_script.tcl"
    with open(tcl_file, "w") as f:
        f.write(tcl_script)

    cmd = [os.path.join(config["vivado_path"], "vivado"), "-mode", "tcl", "-source", tcl_file]
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=os.getcwd())

    os.remove(tcl_file)
    return result.stdout, result.stderr

def create_vivado_project(project_name, part=config["project_part"]):
    """创建新的Vivado工程"""
    tcl = f"""
    create_project {project_name} ./{project_name} -part {part}
    set_property target_language {config["default_language"]} [current_project]
    set_property simulator_language Mixed [current_project]
    set_param general.maxThreads 8
    """
    return run_vivado_tcl(tcl)

def add_source_files(files, file_type="VHDL"):
    """向当前工程添加源文件或约束文件"""
    tcl = ""
    for file in files:
        if file_type == "XDC":
            tcl += f"add_files -fileset constrs_1 {file}\n"
        else:
            tcl += f"add_files {file}\n"
    return run_vivado_tcl(tcl)

def run_synthesis_and_implementation():
    """运行综合和实现"""
    tcl = """
    synth_design
    opt_design
    place_design
    route_design
    report_utilization -file utilization.rpt
    report_timing -file timing.rpt
    """
    stdout, stderr = run_vivado_tcl(tcl)
    return "ERROR" not in stderr, stdout, stderr

def generate_bitstream():
    """生成比特流文件"""
    tcl = "write_bitstream -force ./output.bit"
    return run_vivado_tcl(tcl)

def parse_vivado_log(log):
    """解析Vivado日志，提取错误和警告信息"""
    errors = []
    warnings = []
    for line in log.split("\n"):
        if "ERROR:" in line:
            errors.append(line.strip())
        elif "WARNING:" in line:
            warnings.append(line.strip())
    return {"errors": errors, "warnings": warnings}

def download_bitstream(bit_file):
    """下载比特流到ZYNQ开发板"""
    try:
        from pynq import Overlay
        overlay = Overlay(bit_file)
        return True, f"比特流 {bit_file} 下载成功"
    except Exception as e:
        return False, f"比特流下载失败: {str(e)}"

def create_jupyter_notebook(notebook_name, content):
    """创建Jupyter Notebook文件"""
    nb = nbformat.v4.new_notebook()
    nb.cells.append(nbformat.v4.new_markdown_cell(f"# {notebook_name}"))
    for cell in content:
        if cell["type"] == "markdown":
            nb.cells.append(nbformat.v4.new_markdown_cell(cell["content"]))
        elif cell["type"] == "code":
            nb.cells.append(nbformat.v4.new_code_cell(cell["content"]))
    nbformat.write(nb, f"{notebook_name}.ipynb")
    return True, f"Jupyter Notebook {notebook_name}.ipynb 创建成功"

def save_experiment_data(experiment_name, data, metadata):
    """保存实验数据和元数据"""
    if not os.path.exists("./experiment_data"):
        os.makedirs("./experiment_data")

    timestamp = time.strftime("%Y%m%d_%H%M%S")
    filename = f"./experiment_data/{experiment_name}_{timestamp}.h5"

    with h5py.File(filename, "w") as f:
        f.create_dataset("data", data=data)
        for key, value in metadata.items():
            f.attrs[key] = value

    return True, f"实验数据已保存到 {filename}"

def git_commit(message):
    """提交代码变更到Git仓库"""
    try:
        repo = git.Repo(os.getcwd())
        repo.git.add(A=True)
        repo.index.commit(message)
        return True, f"提交成功: {message}"
    except Exception as e:
        return False, f"Git提交失败: {str(e)}"

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("用法: python hardware_tools.py [命令] [参数]")
        sys.exit(1)

    command = sys.argv[1]
    args = sys.argv[2:]

    if command == "create_vivado_project":
        stdout, stderr = create_vivado_project(*args)
        print(stdout)
        print(stderr)
    elif command == "run_synthesis_and_implementation":
        success, stdout, stderr = run_synthesis_and_implementation()
        print(stdout)
        print(stderr)
        print(f"编译{'成功' if success else '失败'}")
    else:
        print(f"未知命令: {command}")

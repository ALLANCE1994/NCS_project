# Git Push 操作指南

> **来源**：git-push(1) Manual Page
> **用途**：GitHub 同步任务参考手册
> **适用角色**：@G（GitHub 同步管理智能体）

---

## 一、基本用法

### 1.1 最简单的推送

```bash
git push origin main
```

将本地 `main` 分支推送到远程 `origin` 的 `main` 分支。

### 1.2 默认行为

- `<repository>` 默认为当前分支的上游（upstream），如果没有配置则默认为 `origin`
- 推送规则优先级：
  1. 命令行指定的 `<refspec>`（如 `main`）或 `--all/--mirror/--tags` 选项
  2. `remote.<name>.push` 配置
  3. `push.default` 配置（默认为 `simple`）

---

## 二、常用选项

| 选项 | 说明 |
|------|------|
| `--all` / `--branches` | 推送所有分支（`refs/heads/` 下的所有引用） |
| `--tags` | 推送所有标签（`refs/tags/` 下的所有引用） |
| `--follow-tags` | 推送分支时，同时推送指向该分支可达的附注标签 |
| `--mirror` | 镜像推送所有引用（分支、标签、远程跟踪分支等） |
| `--force` / `-f` | 强制推送（覆盖远程历史，**慎用**） |
| `--force-with-lease` | 安全强制推送（仅在远程未更新时强制） |
| `--dry-run` / `-n` | 模拟推送，不实际发送数据 |
| `--delete` / `-d` | 删除远程分支 |
| `--prune` | 删除远程中已无本地对应分支的分支 |
| `--quiet` / `-q` | 静默输出 |
| `--verbose` / `-v` | 详细输出 |
| `--set-upstream` / `-u` | 设置上游分支 |

---

## 三、Refspec 格式

### 3.1 基本格式

```
[<src>][:<dst>]
```

| 示例 | 说明 |
|------|------|
| `main` | 推送本地 `main` 到远程同名分支 |
| `main:other` | 推送本地 `main` 到远程 `other` 分支 |
| `HEAD^:refs/heads/main` | 推送 HEAD 的父提交到远程 `main` |
| `:main` | 删除远程 `main` 分支（`<src>` 为空） |
| `refs/heads/*:refs/heads/*` | 推送所有分支（模式匹配） |

### 3.2 强制推送

在 refspec 前加 `+` 表示允许非快进更新：

```bash
git push origin +main
git push origin +refs/heads/*:refs/heads/*
```

---

## 四、推送规则

### 4.1 快进检查

默认情况下，Git 拒绝非快进推送（即远程分支已有本地没有的提交）。

### 4.2 安全强制推送

```bash
git push --force-with-lease origin main
```

仅在远程分支与本地预期一致时才强制推送，避免覆盖他人提交。

### 4.3 删除远程分支

```bash
git push origin --delete dev
git push origin :dev
```

---

## 五、配置项

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `push.default` | 默认推送行为 | `simple` |
| `push.followTags` | 是否跟随推送标签 | `false` |
| `remote.<name>.push` | 指定远程的默认推送规则 | - |
| `remote.<name>.mirror` | 是否镜像推送 | `false` |

### 5.1 push.default 取值

| 值 | 说明 |
|----|------|
| `nothing` | 不推送任何内容 |
| `current` | 推送当前分支到同名远程分支 |
| `upstream` | 推送到上游分支 |
| `simple` | 类似 `upstream`，但更安全（当前分支名必须与上游名一致） |
| `matching` | 推送所有本地与远程同名的分支（**已弃用**） |

---

## 六、常见场景

### 6.1 首次推送并设置上游

```bash
git push -u origin main
```

### 6.2 推送所有分支

```bash
git push --all origin
```

### 6.3 推送所有标签

```bash
git push --tags origin
```

### 6.4 清理远程已删除的本地分支

```bash
git push --prune origin
```

### 6.5 使用 HTTPS Token 推送

```bash
git remote set-url origin https://<TOKEN>@github.com/USER/REPO.git
git push origin main
```

---

## 七、错误处理

| 错误 | 原因 | 解决 |
|------|------|------|
| `rejected: non-fast-forward` | 远程有本地没有的提交 | 先 `git pull` 或使用 `--force-with-lease` |
| `could not resolve host` | 网络或远程地址错误 | 检查网络连接和远程 URL |
| `Authentication failed` | 认证失败 | 检查 Token 或 SSH 密钥配置 |
| `Permission denied` | 无推送权限 | 检查仓库权限设置 |

---

**维护责任**：@G（GitHub 同步管理智能体）
**更新日期**：2026-05-17

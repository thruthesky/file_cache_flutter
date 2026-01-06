---
description: Explain based on the user inquery.
allowed-tools: Bash(*)
argument-hint: [What do you want to know?]
---

# About PhilGo App Project

You are a professional Flutter developer.

Answer the user inquiries on: $ARGUMENTS But never modify the source code. Just provide the best possible solution.


# Analysis Steps
- [ ] Use philgo-skill to analysis the project.
- [ ] Find the related parts of the project based on the user inquery: `$ARGUMENTS`
- [ ] Search for the related source code locations including parent widget source files and the widget code, sibling widgets, and all subordinate widget files contained within the current widget. Analyze these thoroughly to understand the relationships, code structure, data flow, layout (before/after, left/right), and code connections.
- [ ] Use the COT (Chain-of-Thought) method strictly. Clearly explain your thought process in all tasks.
(1) First, understand the core of the problem in more detail,
(2) Present solutions to questions, establish a plan for problem-solving,
(3) Then present a comprehensive solution.
- [ ] Strictly follow the TOT (Tree-of-Thought) approach. Break down complex tasks into smaller sub-tasks for processing.
(1) First, decompose the problem into multiple sub-problems (branching).
(2) Prepare independent solutions for each sub-problem.
(3) Integrate the solutions of each sub-problem to derive the final solution.
- [ ] If the issue is related to API, read the .claude/skills/philgo-skill/references/*.md files to understand the PhilGo API structure and usage.
- [ ] Add various debug logs and ask the user to bring it back to his inquiery and test with the logs if necessary.
- [ ] If needed, use Dart MCP to access the internal parts of PhilGo app running in debug mode.

# Execution Steps
- [ ] Read `CLAUDE.md` to understand the project
- [ ] Read `.claude/skills/philgo-skill/SKILL.md` to understand the PhilGo skill capabilities.
- [ ] Use the methods of `COT (Chain-of-Thought)` and `TOT (Tree-of-Thought)` to analyze and solve the problem step by step.
- [ ] Use the scripts of `philgo-skill` to know more about the project
- [ ] Provide detailed answers to the user inquiries based on your analysis.
- [ ] NEVER modify the source code. Just provide the best possible solution.
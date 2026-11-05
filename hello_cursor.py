"""Send one prompt with a Cursor user API key and print the reply.

Usage:
    export CURSOR_API_KEY="the full key from the dashboard dialog"
    python3 hello_cursor.py
"""

import os
import sys

from cursor_sdk import Agent, AgentOptions, LocalAgentOptions


def main() -> int:
    api_key = os.environ.get("CURSOR_API_KEY", "").strip()
    if not api_key:
        print(
            "缺少环境变量 CURSOR_API_KEY。到仪表盘再创建一个密钥，在弹窗里复制完整字符串后执行：\n"
            "  export CURSOR_API_KEY='你的完整密钥'\n"
            "  python3 hello_cursor.py",
            file=sys.stderr,
        )
        return 1

    result = Agent.prompt(
        "你好",
        AgentOptions(
            model="grok-4.7",
            api_key=api_key,
            tools=[],
            local=LocalAgentOptions(cwd=os.getcwd()),
        ),
    )
    print(f"status: {result.status}")
    if result.model is not None:
        print(f"model: {result.model.id}")
    if result.error_message:
        print(f"error: {result.error_message}", file=sys.stderr)
    print(result.result)
    return 0 if result.status == "finished" else 1


if __name__ == "__main__":
    raise SystemExit(main())

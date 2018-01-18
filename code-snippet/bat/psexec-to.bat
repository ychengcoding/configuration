localset last_part=%1
echo psexec \\10.235.61.%1 -u administrator -password AAAaaa111 cmd
start cmd /k "psexec \\10.235.61.%1 -u administrator -password AAAaaa111 cmd"
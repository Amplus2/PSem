#!/bin/sh

echo "<div class='actual-body'><h2>Build</h2>Time: $(date)<br>Commit: $(git rev-parse HEAD)<br>Machine: $(uname -a)</div>"

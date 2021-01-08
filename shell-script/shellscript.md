## process-relative

```shell

$ps | grep python | grep -v grep | awk '{print $1}' | xargs kill -9
#ps | grep Xcode | grep -v grep | awk '{print $1}' | xargs kill -9
#explation
$ps
  PID TTY           TIME CMD
 2468 ttys001    0:00.19 /bin/bash --rcfile /Applications/IntelliJ IDEA.app/Contents/plugins/terminal/jediterm-bash.in -i
 4603 ttys002    0:00.05 /Applications/iTerm 2.app/Contents/MacOS/iTerm2 --server login -fp mac
 4605 ttys002    0:00.37 -bash
13904 ttys003    0:00.07 /Applications/iTerm 2.app/Contents/MacOS/iTerm2 --server login -fp mac
13906 ttys003    0:00.12 -bash
14152 ttys003    0:00.01 ping account.tiktok.com
23097 ttys004    0:00.06 /Applications/iTerm 2.app/Contents/MacOS/iTerm2 --server login -fp mac
23099 ttys004    0:00.12 -bash
24054 ttys005    0:00.06 /Applications/iTerm 2.app/Contents/MacOS/iTerm2 --server login -fp mac
24056 ttys005    0:00.16 -bash
24377 ttys005    0:00.03 /bin/bash /usr/local/Homebrew/Library/Homebrew/brew.sh tap caffix/amass
24520 ttys005    0:00.04 /bin/bash /usr/local/Homebrew/Library/Homebrew/brew.sh update --preinstall
24738 ttys005    0:00.00 /bin/bash /usr/local/Homebrew/Library/Homebrew/brew.sh update --preinstall
24779 ttys005    0:00.16 /Applications/Xcode.app/Contents/Developer/usr/bin/git fetch --tags --force -q origin refs/heads/master:refs/remotes/origin/master
24780 ttys005    0:01.28 /Applications/Xcode.app/Contents/Developer/usr/libexec/git-core/git-remote-https origin https://github.com/Homebrew/homebrew-cask
25004 ttys005    0:01.70 /Applications/Xcode.app/Contents/Developer/usr/libexec/git-core/git fetch-pack --stateless-rpc --stdin --lock-pack --thin --no-progress https://github.com/Homebrew/homebrew-cask/
25023 ttys005    0:00.04 /Applications/Xcode.app/Contents/Developer/usr/libexec/git-core/git index-pack --stdin --fix-thin --keep=fetch-pack 25004 on Richard-macbookdeMacBook-Pro.local --pack_header=2,105282
$ps | grep python
10727 ttys002    0:00.20 python3 sublist3r.py -v -d ibm.com
10728 ttys002    0:00.44 python3 sublist3r.py -v -d ibm.com
10731 ttys002    0:00.00 (python3)
10732 ttys002    0:00.00 (python3)
10733 ttys002    0:00.00 (python3)
10734 ttys002    0:00.00 (python3)
10735 ttys002    0:00.00 (python3)
10736 ttys002    0:00.00 (python3)
10737 ttys002    0:00.00 (python3)
10738 ttys002    0:00.00 (python3)
10739 ttys002    0:00.00 (python3)
26987 ttys005    0:00.00 grep python
$ps | grep python | grep -v grep
10727 ttys002    0:00.20 python3 sublist3r.py -v -d ibm.com
10728 ttys002    0:00.44 python3 sublist3r.py -v -d ibm.com
10731 ttys002    0:00.00 (python3)
10732 ttys002    0:00.00 (python3)
10733 ttys002    0:00.00 (python3)
10734 ttys002    0:00.00 (python3)
10735 ttys002    0:00.00 (python3)
10736 ttys002    0:00.00 (python3)
10737 ttys002    0:00.00 (python3)
10738 ttys002    0:00.00 (python3)
10739 ttys002    0:00.00 (python3)
```

`grep -v grep` 的作用是除去本次操作所造成的影响，-v 表示反向选择。

` awk '{print $1}'` 表示筛选出我们所关注的进程号，`$1` 表示每行第一个变量，在这个例子中就是进程号。所以如果你使用ps工具不一样，或者ps带的参数不一样，那需要关注的就可能不是`$1`，可能是`$2` 。

 `xargs kill -9 `中的 `xargs` 命令表示用前面命令的输出结果（也就是一系列的进程号）作为 kill -9 命令的参数，-9 表示强制终止，不是必须的。



## simple-bash script

[generate_special_length_string.sh](./generate_special_length_string.sh)

[cal_string_length.sh](./cal_string_length.sh) :       usage : `sh  cal_string_length.sh  string_that_you_want_to_cal_its_length`







 
# Beam Robot Docker image

This is a skunkworks/Passion project to get the Beam robot working again.

The current `beam-2.22.1-Linux.deb` package won't install and run on current versions of Ubuntu linux 
due to some really out of date dependencies.

This is an attempt to Docker-ify a GUI app that relies on being able to talk to the video camera and
the sound card on a modern linux machine so those of us who are running Linux as their daily driver 
computer can use the Beam telepresence bot.

## Assumptions

- We can get a Docker container to talk to the current XWindows session by exporting the `DISPLAY` env var.
- We can get the Docker container to talk to the webcam
- We can get the Docker container to talk to the sound card
- We can figure out all the weird dependencies required by the beam package enough to build the image

## Things that likely won't work:

- Getting a Beam icon on the host desktop (unless each user manually creates one to run the docker
container)
- a super-slick install. Most likely, the user will have to create a docker command that exposes their
camera and sound card, and it'll be different for each user. Since we're expecting Linux users to be 
pretty tech savvy, we'll provide instructions, but not a slick installer that figures out all the things
to make the `docker run` command bullet proof.

## The idea:

Create a minimal-ish container that has the beam binary's entrypoint coded up to be able to run a
`docker run --$connect-to-display --$connect-to-soundcard --volume ~/.beam:$beam_config particle/beam`
command and have it launch the Beam controller on a Linux desktop. We'll probably start with supporting
Gnome shell, as it's probably the most common at Particle. KDE would be nice too.


## Notes:

beam-2.22.1-Linux.deb relies on:
```
libxcb-icccm4 libxcb-image0 libunwind8 libpulse0
```

It also seems to rely on `xdg-tools` to have a `xdg-icon-resource` and a directory to stick the icon in.
The `dpkg -i beam-2.22.1-Linux.deb` install throws a bunch of warnings (not sure if they're errors).
Let's just run it and see...

---

```
% docker run -ti --rm beam-robot:latest /bin/bash
root@29831b4a56c9:/# beam
/opt/suitable/beam/bin/beam: error while loading shared libraries: libusb-1.0.so.0: cannot open shared object file: No such file or directory
```
---

Try it with connections to the display, sound card and video card:

```bash
% docker run -it --rm \
>     -v /tmp/.X11-unix:/tmp/.X11-unix \
>     -e DISPLAY=$DISPLAY \
>     --device /dev/snd \
>     --device /dev/video0 \
>     --name beam \
>     beam-robot:latest
ERR 2019-08-29 22:03:26.371417 140508595685248 common/http_upload_curl.cpp:218 Could not load libcurl.  Uploads will all fail
New client, pid 6
INF 2019-08-29 22:03:26.373938 140065743997248 common/global_history_dumps.cpp:110 Saving history dumps to: /root/.beam/history_dump
INF 2019-08-29 22:03:26.374038 140065743997248 common/common.cpp:204 Machine UUID: LINUX
INF 2019-08-29 22:03:26.374043 140065743997248 common/common.cpp:205 Run_id: 71A3B314C495D5FED44CF763B36F3D3D
INF 2019-08-29 22:03:26.374189 140065743997248 app/component_initializer.cpp:115 Starting application /opt/suitable/beam/bin/beam
INF 2019-08-29 22:03:26.374212 140065354876672 common/history_dump.cpp:165 Enabling history dump trigger: debug/history_dump/continuous/force_enable
INF 2019-08-29 22:03:26.374251 140065354876672 common/history_dump.cpp:165 Enabling history dump trigger: debug/history_dump/immediate/force_enable
INF 2019-08-29 22:03:26.374279 140065304520448 common/history_dump.cpp:501 Starting history dump.
INF 2019-08-29 22:03:26.374285 140065354876672 common/history_dump.cpp:165 Enabling history dump trigger: debug/history_dump/slow_immediate/force_enable
INF 2019-08-29 22:03:26.374323 140065296127744 common/history_dump.cpp:501 Starting history dump.
INF 2019-08-29 22:03:26.374821 140065287735040 common/history_dump.cpp:501 Starting history dump.
sh: 1: lsb_release: not found
ERR 2019-08-29 22:03:26.375561 140065743997248 common/system_info.cpp:91 pipe read error
WRN 2019-08-29 22:03:26.375566 140065743997248 common/system_info.cpp:246 failed to get OS description via command: lsb_release -d
No protocol specified
WRN 2019-08-29 22:03:26.377751 140065743997248 qtquick-gui/init.cpp:131 (null):0 ((null)): QXcbConnection: Could not connect to display :0
ERR 2019-08-29 22:03:26.377769 140065743997248 qtquick-gui/init.cpp:134 CRITICAL (null):0 ((null)): Could not connect to any X display.
ERR 2019-08-29 22:03:26.378559 140065743997248 common/initializer.h:234 Assertion failed: scoped_initialization_.expired(), at /teamcity/work/9b2edaf8f9186cfa/stacks/texas_videoconf/vcclient/common/initializer.h:234
ERR 2019-08-29 22:03:26.379066 140065743997248 common/backtrace.cpp:150 0 -> /opt/suitable/beam/bin/libcommon.so bacon::Backtrace::Backtrace(unsigned long) +0x11b [0x7f63977111eb]
ERR 2019-08-29 22:03:26.379073 140065743997248 common/backtrace.cpp:150 1 -> /opt/suitable/beam/bin/libcommon.so bacon::handleAssertion(char const*, int, char const*, char const*, ...) +0x227 [0x7f639770f047]
ERR 2019-08-29 22:03:26.379076 140065743997248 common/backtrace.cpp:150 2 -> /opt/suitable/beam/bin/libcommon.so bacon::InitializableT<bacon::TimerWatchdogGlobals>::~InitializableT() +0x160 [0x7f63977e69e0]
ERR 2019-08-29 22:03:26.379078 140065743997248 common/backtrace.cpp:150 3 -> /lib/x86_64-linux-gnu/libc.so.6(__cxa_finalize+0x99) [0x7f6396ac3369]
ERR 2019-08-29 22:03:26.379079 140065743997248 common/backtrace.cpp:150 4 -> /opt/suitable/beam/bin/libcommon.so(+0xd7262) [0x7f6397702262]
INF 2019-08-29 22:03:26.380143 140065743997248 common/history_dump.cpp:165 Enabling history dump trigger: assertion_or_crash
INF 2019-08-29 22:03:26.380178 140065743997248 common/history_dump.cpp:148 Disabling history dump trigger (snapshotting=0): assertion_or_crash
INF 2019-08-29 22:03:26.380197 140065262122752 common/history_dump.cpp:501 Starting history dump.
INF 2019-08-29 22:03:26.380327 140065262122752 common/history_dump.cpp:601 Stopping history dump.
FTL 2019-08-29 22:03:26.380358 140065262122752 common/file/local_file.cpp:495 Check failed fd > 0 
ERR 2019-08-29 22:03:26.380361 140065262122752 common/logging.cpp:515 Assertion failed: Reached terminating log level. Terminating
, at /teamcity/work/9b2edaf8f9186cfa/stacks/texas_videoconf/vcclient/common/logging.cpp:515
ERR 2019-08-29 22:03:26.381192 140065262122752 common/backtrace.cpp:150 0 -> /opt/suitable/beam/bin/libcommon.so bacon::Backtrace::Backtrace(unsigned long) +0x11c [0x7f63977111ec]
ERR 2019-08-29 22:03:26.381196 140065262122752 common/backtrace.cpp:150 1 -> /opt/suitable/beam/bin/libcommon.so bacon::handleAssertion(char const*, int, char const*, char const*, ...) +0x228 [0x7f639770f048]
ERR 2019-08-29 22:03:26.381197 140065262122752 common/backtrace.cpp:150 2 -> /opt/suitable/beam/bin/libcommon.so bacon::LoggingStream::~LoggingStream() +0x2a1 [0x7f6397792241]
ERR 2019-08-29 22:03:26.381199 140065262122752 common/backtrace.cpp:150 3 -> /opt/suitable/beam/bin/libcommon.so bacon::LocalFile::pread(unsigned long, void*, unsigned long) +0x192 [0x7f639776a862]
ERR 2019-08-29 22:03:26.381200 140065262122752 common/backtrace.cpp:150 4 -> /opt/suitable/beam/bin/libcommon.so bacon::File::readFileToString(std::string const&, std::string*) +0xcc [0x7f639776616c]
ERR 2019-08-29 22:03:26.381201 140065262122752 common/backtrace.cpp:150 5 -> /opt/suitable/beam/bin/libcommon.so bacon::compressDump(std::string*) +0x4e [0x7f6397775efe]
ERR 2019-08-29 22:03:26.381203 140065262122752 common/backtrace.cpp:150 6 -> /opt/suitable/beam/bin/libcommon.so bacon::HistoryDumpPrivate::closeDump(bacon::HistoryDumpWriter*, bacon::DumpInfo) +0x180 [0x7f63977776a0]
ERR 2019-08-29 22:03:26.381205 140065262122752 common/backtrace.cpp:150 7 -> /opt/suitable/beam/bin/libcommon.so std::_Sp_counted_deleter<bacon::HistoryDumpWriter*, std::_Bind<std::_Mem_fn<void (bacon::HistoryDumpPrivate::*)(bacon::HistoryDumpWriter*, bacon::DumpInfo)> (bacon::HistoryDumpPrivate*, std::_Placeholder<1>, bacon::DumpInfo)>, std::allocator<int>, (__gnu_cxx::_Lock_policy)2>::_M_dispose() +0x79 [0x7f639777ba49]
ERR 2019-08-29 22:03:26.381206 140065262122752 common/backtrace.cpp:150 8 -> /opt/suitable/beam/bin/beam std::_Sp_counted_base<(__gnu_cxx::_Lock_policy)2>::_M_release() +0x61 [0x55c9767f4851]
ERR 2019-08-29 22:03:26.381209 140065262122752 common/backtrace.cpp:150 9 -> /opt/suitable/beam/bin/libcommon.so bacon::HistoryDumpPrivate::dumpThread() +0x1097 [0x7f639777a757]
ERR 2019-08-29 22:03:26.381210 140065262122752 common/backtrace.cpp:150 10 -> /opt/suitable/beam/bin/libcommon.so bacon::ThreadPrivate::starter(void*) +0xa5 [0x7f63977f2055]
ERR 2019-08-29 22:03:26.381211 140065262122752 common/backtrace.cpp:150 11 -> /lib/x86_64-linux-gnu/libpthread.so.0(+0x76ba) [0x7f63917156ba]
ERR 2019-08-29 22:03:26.381213 140065262122752 common/backtrace.cpp:150 12 -> /lib/x86_64-linux-gnu/libc.so.6(clone+0x6d) [0x7f6396b9041d]
ERR 2019-08-29 22:03:26.381214 140065262122752 common/backtrace.cpp:150 13 -> [(nil)]
ERR 2019-08-29 22:03:28.372346 140065363269376 common/thread/pthread/mutex.cpp:305 Assertion failed: Call to pthread function returned (22) Invalid argument, at /teamcity/work/9b2edaf8f9186cfa/stacks/texas_videoconf/vcclient/common/thread/pthread/mutex.cpp:305
ERR 2019-08-29 22:03:28.375538 140065363269376 common/backtrace.cpp:150 0 -> /opt/suitable/beam/bin/libcommon.so bacon::Backtrace::Backtrace(unsigned long) +0x11c [0x7f63977111ec]
ERR 2019-08-29 22:03:28.375564 140065363269376 common/backtrace.cpp:150 1 -> /opt/suitable/beam/bin/libcommon.so bacon::handleAssertion(char const*, int, char const*, char const*, ...) +0x228 [0x7f639770f048]
ERR 2019-08-29 22:03:28.375574 140065363269376 common/backtrace.cpp:150 2 -> /opt/suitable/beam/bin/libcommon.so bacon::ConditionVariable::timedWaitRelative(bacon::Mutex&, bacon::Duration const&) +0xab [0x7f63977efbab]
ERR 2019-08-29 22:03:28.375585 140065363269376 common/backtrace.cpp:150 3 -> /opt/suitable/beam/bin/libcommon.so bacon::Watchdog::Impl::watchdogThread() +0x133 [0x7f63977fa363]
ERR 2019-08-29 22:03:28.375593 140065363269376 common/backtrace.cpp:150 4 -> /opt/suitable/beam/bin/libcommon.so bacon::ThreadPrivate::starter(void*) +0xa5 [0x7f63977f2055]
ERR 2019-08-29 22:03:28.375603 140065363269376 common/backtrace.cpp:150 5 -> /lib/x86_64-linux-gnu/libpthread.so.0(+0x76ba) [0x7f63917156ba]
ERR 2019-08-29 22:03:28.375612 140065363269376 common/backtrace.cpp:150 6 -> /lib/x86_64-linux-gnu/libc.so.6(clone+0x6d) [0x7f6396b9041d]
ERR 2019-08-29 22:03:28.375621 140065363269376 common/backtrace.cpp:150 7 -> [(nil)]
INF 2019-08-29 22:03:28.380341 140065262122752 common/history_dump.cpp:165 Enabling history dump trigger: assertion_or_crash
INF 2019-08-29 22:03:28.380373 140065262122752 common/history_dump.cpp:148 Disabling history dump trigger (snapshotting=0): assertion_or_crash
Crash! Client with PID 6 crashed. Sending /root/.beam/crash/0a9b1198-9013-dad5-05c45522-46ec9270.dmp to the crash server
Uploading /root/.beam/crash/0a9b1198-9013-dad5-05c45522-46ec9270.dmp to the server (probably via NoProxy -- there are races)
ERR 2019-08-29 22:03:28.451823 140508500059904 common/http_upload_curl.cpp:287 Could not upload file because curl not configured
Failed to upload /root/.beam/crash/0a9b1198-9013-dad5-05c45522-46ec9270.dmp to the server
Client exited, pid 6
Trace/breakpoint trap (core dumped)
```

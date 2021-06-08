
<h3>How it works</h3>
      

<p>dionaea intention is to trap malware exploiting vulnerabilities exposed by services offered to a network, the ultimate goal is gaining a copy of the malware.
</p>
<h3>Security</h3>
<p>
As Software is likely to have bugs, bugs in software offering network services can be exploitable, and dionaea is software offering network services, it is likely dionaea has exploitable bugs.

Of course we try to avoid it, but if nobody would fail when trying hard, we would not need software such as dionaea.

So, in order to minimize the impact, dionaea can drop privileges, and chroot.

To be able to run certain actions which require privileges, after dionaea dropped them, dionaea creates a child process at startup, and asks the child process to run actions which require elevated privileges. This does not guarantee anything, but it should be harder to get gain root access to the system from an unprivileged user in a chroot environment.
  </p>
<h3>Network Connectivity</h3>
<p>
Given the softwares intended use, network io is crucial. All network io is within the main process in a so called non-blocking manner. To understand nonblocking, imagine you have many pipes infront of you, and these pipes can send you something, and you can put something into the pipe. If you want to put something into a pipe, while it is crowded, you’d have to wait, if you want to get something from a pipe, and there is nothing, you’d have to wait too. Doing this pipe game non-blocking means you won’t wait for the pipes to be write/readable, you’ll get something off the pipes once data arrives, and write once the pipe is not crowded. If you want to write a large chunk to the pipe, and the pipe is crowded after a small piece, you note the rest of the chunk you wanted to write, and wait for the pipe to get ready.

DNS resolves are done using libudns, which is a neat non-blocking dns resolving library with support for AAAA records and chained cnames. So much about non-blocking.

dionaea uses libev to get notified once it can act on a socket, read or write.

dionaea can offer services via tcp/udp and tls for IPv4 and IPv6, and can apply rate limiting and accounting limits per connections to tcp and tls connections - if required.
  </p>

<h3>Docker RUN CMD</h3>
<p>
 docker run
-e ip="Open Distro for Elasticsearch IP"
-e user="Open Distro for Elasticsearch user"
-e password="Open Distro for Elasticsearch password"
--rm -d
-p 21:21
-p 42:42
-p 69:69/udp
-p 80:80
-p 135:135
-p 443:443
-p 445:445
-p 1433:1433
-p 1723:1723
-p 1883:1883
-p 1900:1900/udp
-p 3306:3306
-p 5060:5060
-p 5060:5060/udp
-p 5061:5061
-p 11211:11211
kkpkishan/dionaea:v1
      </p>

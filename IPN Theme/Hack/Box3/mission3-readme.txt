Mission 3: The Spider (Web Enumeration)
- Login with user hack_IPN3 / pass hack_IPN3.
- Scan the bridge network (172.17.0.0/24) or localhost to find the web server running the summit site.
- Use gobuster with the provided wordlist: gobuster -u http://<TARGET_IP>:80 -w /home/hack_IPN3/gobuster-500.txt -t 30 -q
- Hidden directories contain distractions; the real goal is the /secrets page with the admin hash and flag.

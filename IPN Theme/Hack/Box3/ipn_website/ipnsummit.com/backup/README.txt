IPN Summit | Backup Timeline (logbook kept by infra volunteers)

- 2024-11-15: Imported legacy speaker bios from 2024 showcase into the 2026 Webflow export for safekeeping.
- 2024-12-08: Content freeze rehearsal — static copy stashed in /var/backups/ipn-prelaunch.tar.gz.
- 2024-12-18: Ticketing CTA swap tested, rollback snapshot created (ipn-ticketing-ab-test.tgz).
- 2024-12-27: Venue switch banner (Ismaili Center + GRB) pushed; backup saved to cold storage S3 (glacier tier).
- 2025-01-02: On-site kickoff backup at 05:00 CST before doors opened at the Ismaili Center.
- 2025-01-03: Mid-summit integrity check; cached assets pushed to edge bucket and mirrored to dev FTP.
- 2025-01-04: Post-closing backup of JAN 02-04, 2026 program pages for archive + compliance.
- 2025-01-05: Retention policy rotated; anything older than 180 days quarantined. Use offsite tape if absolutely necessary.

If you're hunting for secrets, this folder is the decoy. Real backups live offsite with MFA and audit logs.

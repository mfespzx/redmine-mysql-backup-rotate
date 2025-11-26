# Redmine MySQL Backup & Rotation Script

This script is designed for environments running multiple Redmine (MySQL) instances.  
It automatically performs database dumps from MySQL containers running under Podman and handles backup rotation for each instance.

It is intended for multi-tenant Redmine setups, or environments where Redmine and MySQL/MariaDB containers are managed individually via Podman or Docker.

---

## ■ Overview

- Automatically scans all Redmine instances under `BASE_DIR`  
- Executes `mysqldump` against the corresponding MySQL container  
- Compresses dump files with gzip  
- Rotates backups based on a specified number of generations  
- Uses `pipefail` for proper error detection  
- Saves logs per instance, suitable for operational environments  

---

## ■ Script Name


---

## ■ Requirements

- Linux (CentOS / Rocky / Ubuntu, etc.)
- Podman  
- Redmine (Rails)  
- MySQL or MariaDB  
- Bash shell  

---

## ■ Directory Structure Example

Edit the required variables such as `BASE_DIR` at the top of the script to match your environment.

Example:


The script will automatically perform database backups and rotate them for each Redmine instance detected under `BASE_DIR`.




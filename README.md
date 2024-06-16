# 🚀 ansible-app-updater

This Ansible project automates the process of updating and patching an application on a remote server. It includes various roles and tasks to ensure the update process is seamless and logs are properly monitored.

## 📂 Project Structure

```plaintext
/ansible-app-updater
|-- ansible.cfg
|-- hosts
|-- playbook.yml
|-- roles/
    |-- update_and_patch/
        |-- tasks/
            |-- main.yml
            |-- copy_to_remote.yml
            |-- copy_to_target.yml
            |-- execute_curl.yml
            |-- verify_update.yml
        |-- vars/
            |-- main.yml
```

## 📄 Files and Directories

### 🔧 ansible.cfg

This file contains the Ansible configuration settings:

```ini
[defaults]
inventory = /path/to/your/hosts
remote_user = your_remote_user
host_key_checking = False
```

### 🌐 hosts

This file defines the target hosts for the Ansible playbook:

```plaintext
[webservers]
your_remote_host ansible_ssh_private_key_file=/path/to/your/private/key
```

### 📜 playbook.yml

This is the main playbook that includes the `update_and_patch` role:

```yaml
---
- name: Update and patch application
  hosts: all
  vars_files:
    - roles/update_and_patch/vars/main.yml
  tasks:
    - include_role:
        name: update_and_patch
```

### 🔧 roles/update_and_patch/vars/main.yml

This file defines variables used in the `update_and_patch` role:

```yaml
file_to_update: "example-update-file.tar.gz.enc"
remote_builds_directory: "/var/www/your_app/bin/builds"
local_target_directory: "/var/www/html/your_app/storage/app/patches"
log_file_path: "/var/www/html/services/update-toolbox/app.log"
local_tmp: "/tmp/"
```

### 📝 roles/update_and_patch/tasks/main.yml

This file includes all the necessary tasks for the `update_and_patch` role:

```yaml
- name: Copy the file to the remote server
  include_tasks: copy_to_remote.yml

- name: Copy file from remote server to target directory
  include_tasks: copy_to_target.yml

- name: Execute the curl command
  include_tasks: execute_curl.yml

- name: Wait for 5 minutes before checking the log file
  ansible.builtin.pause:
    minutes: 5

- name: Verify the update process
  include_tasks: verify_update.yml
```

### 📦 roles/update_and_patch/tasks/copy_to_remote.yml

This task copies the update file from a remote build server to the Ansible controller's local temporary directory:

```yaml
- name: Copy the file from the remote server using scp
  ansible.builtin.command: >
    scp your_user@build_server:/path/to/remote/builds/{{ file_to_update }} {{ local_tmp }}
  delegate_to: localhost
```

### 📂 roles/update_and_patch/tasks/copy_to_target.yml

This task copies the update file from the Ansible controller's local temporary directory to the target directory on the remote server:

```yaml
- name: Copy file from local to target directory
  ansible.builtin.copy:
    src: "{{ local_tmp }}/{{ file_to_update }}"
    dest: "{{ local_target_directory }}"
```

### 🌐 roles/update_and_patch/tasks/execute_curl.yml

This task executes a curl command to apply the patch:
example:
```yaml
- name: Execute the curl command
  ansible.builtin.shell: curl "http://localhost:9990/patch?version={{ file_to_update }}"
  register: curl_output
```

### ✅ roles/update_and_patch/tasks/verify_update.yml

This task verifies that the update was successful by checking the log file:

```yaml
- name: Copy the verify_update.sh script to the remote server
  ansible.builtin.copy:
    src: /tmp/ansible-app-updater/verify_update.sh
    dest: /tmp/verify_update.sh
    mode: '0755'

- name: Execute the verify_update.sh script
  ansible.builtin.shell: /tmp/verify_update.sh
  register: verify_update_result
  ignore_errors: yes

- name: Fail if the update did not complete successfully
  ansible.builtin.fail:
    msg: "Update did not complete successfully. Check the log for details."
  when: verify_update_result.rc != 0

- name: Display success message
  ansible.builtin.debug:
    msg: "Update completed successfully."
  when: verify_update_result.rc == 0
```

## 🛠️ Verify Update Script

Ensure that your `verify_update.sh` script is correctly placed at `/tmp/ansible-app-updater/verify_update.sh`. The script should handle the following:

1. Empty the log file.
2. Pause for 30 seconds.
3. Check the first log entry.
4. Pause for 3 minutes.
5. Check the last log entry.
6. Display appropriate messages based on the log content.

Example `verify_update.sh`:

```bash
#!/bin/bash

log_file="/var/www/html/services/update-toolbox/app.log"
current_date=$(date +%Y/%m/%d)

# Empty the log file
echo -n > "$log_file"
echo "Log file emptied."

# Pause for 30 seconds
sleep 30

# Check the first log entry
first_log_entry=$(head -n 1 "$log_file")
if [[ "$first_log_entry" != *"$current_date"* || "$first_log_entry" != *"Started"* ]]; then
  echo "The first log entry is not from today or does not start with 'Started'"
  exit 1
fi

# Pause for 3 minutes
sleep 180

# Check the last log entry
last_log_entry=$(tail -n 1 "$log_file")
if [[ "$last_log_entry" == *"$current_date"* && "$last_log_entry" == *"Completed Update"* ]]; then
  echo "Update completed successfully."
  exit 0
else
  echo "Update did not complete successfully. Last log entry: $last_log_entry"
  exit 1
fi
```

## 🔒 Security Considerations

- Avoid hardcoding sensitive information such as IP addresses, usernames, and paths.
- Ensure proper permissions for all files and directories involved in the update process.
- Use SSH keys for secure communication between servers.

## 🚀 Usage

1. Clone the repository to your local machine.
2. Update the `hosts` file with the appropriate remote hosts.
3. Update `vars/main.yml` with the correct paths and filenames.
4. Run the playbook:

```sh
ansible-playbook playbook.yml
```

This will start the update and patch process, ensuring the application is updated correctly and logs are properly monitored.
```

Feel free to tweak this further to suit your preferences!

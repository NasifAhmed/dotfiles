
# 📂 SQL Class Lab Environment

**Teacher's Manual & Student Guide** *A zero-install, Docker-based SQL classroom for FE Exam preparation.*

---

## 🏗️ Teacher Setup (Host Machine)

### 1. Prerequisites
Ensure you have the three scripts saved in this folder and executable:
* `start_class.sh`
* `reset_db.sh`
* `full_reset.sh`

(Run `chmod +x *.sh` in your terminal to make them executable).

### 2. Running the Class
1.  **Start the Environment:**
    ```bash
    ./start_class.sh
    ```
    *This will output the **URL** you need to share with students.*

2.  **Initialize the Database:**
    ```bash
    ./reset_db.sh
    ```
    *Run this once at the start to create the tables and data.*

### 3. Troubleshooting Commands
* **Reset Data Only:** Run `./reset_db.sh` if a student deletes the data.
* **Factory Reset:** Run `./full_reset.sh` if the Docker containers get stuck.
* **Teacher Login:** Run `./enter_db.sh` to log in via terminal as root.

---

# 🎓 SQL Student Guide

## 🔌 How to Connect

1.  **Open your Web Browser** (Chrome, Safari, or Edge).
2.  **Go to the URL** provided by your teacher (e.g., `http://192.168.1.XX:8080`).
3.  **Log In** using these exact details:

| Field | Value | Important Note |
| :--- | :--- | :--- |
| **System** | `MySQL` | Leave this as MySQL |
| **Server** | `mysql-class` | **Do NOT** type an IP address here |
| **Username** | `student1` | |
| **Password** | `student1` | |
| **Database** | `class_db` | |

4.  Click **SQL Command** on the left sidebar to start.

---


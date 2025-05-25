# limit-bandwidth

Assign Low, Medium, or High speeds per user

Run the script per authenticated user (e.g., from your chilli_query script or manually)

Easily update or change plans

sudo ./apply_bandwidth.sh 10.1.0.55 low
sudo ./apply_bandwidth.sh 10.1.0.78 high

GAMMU SETUP

🔧 1. Install MySQL/MariaDB and create a database
sudo apt install mariadb-server
sudo mysql_secure_installation

Then log into MySQL:

sudo mysql -u root -p

And run:
CREATE DATABASE gammu;
CREATE USER 'gammu'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT ALL PRIVILEGES ON gammu.* TO 'gammu'@'localhost';
FLUSH PRIVILEGES;
EXIT;

📦 2. Set up the database schema
Gammu provides the SQL schema for you:

mysql -u gammu -p gammu < /usr/share/doc/gammu examples/sql/mysql.sql

⚙️ 3. Edit /etc/gammu-smsdrc to use the MySQL backend
Open your Gammu SMSD config:

sudo nano /etc/gammu-smsdrc

[gammu]
# Please configure this!
port = /dev/ttyUSB0
connection = at115200
# Debugging
#logformat = textall

# SMSD configuration, see gammu-smsdrc(5)
[smsd]
service = sql
logfile = syslog
# Increase for debugging information
debuglevel = 0
driver = native_mysql
# Paths where messages are stored
inboxpath = /var/spool/gammu/inbox/
outboxpath = /var/spool/gammu/outbox/
sentsmspath = /var/spool/gammu/sent/
errorsmspath = /var/spool/gammu/error/
host = localhost
user = gammu
password = lebona@123
database = gammu
deleteafterreceive = yes

sudo systemctl restart gammu-smsd

mysql -u gammu -p gammu


✅ 4. Check file ownership and permissions
If gammu-smsd can’t write to the DB, it may be running as the wrong user or missing access.

Run: ps aux | grep gammu

Check what user is running the service (often gammu or root).

Then make sure /etc/gammu-smsdrc is readable by that user:

sudo chmod 644 /etc/gammu-smsdrc
sudo chown root:root /etc/gammu-smsdrc

Check logs here:
sudo tail -f /var/log/gammu-smsd.log

# SMS processor
✅ How to Run
npm init
npm install mysql2 dotenv

node index.js


## I can came across something new i havent used
🧠 What are Webhooks?
Webhooks are a way for one system to send real-time data to another system as soon as something happens — like a push notification for backend services.

✅ What You’re Adding
You’ll call an external URL (your webhook) 
like:POST https://yourserver.com/api/payment-hook
add it to .env
{
  "phone": "+26771234567",
  "amount": 10,
  "transactionId": "MP123XYZ",
  "package": "1 Hour"
}

🔧 1. Install Axios
In your sms-processor/ directory:
npm install axios


🧠 How It Works at a High Level
Your flow would now look like:

[SMS received] ➝ [Gammu inserts into inbox] ➝ [Node.js parses SMS]
➝ [Webhook triggered with payment info]
➝ [CoovaChilli login query]
➝ [User gets access to internet]

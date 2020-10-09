sudo su - dash
cd &&\
git clone https://github.com/dashpay/sentinel &&\
cd sentinel &&\
virtualenv venv &&\
venv/bin/pip install -r requirements.txt &&\
venv/bin/py.test test &&\
venv/bin/python bin/sentinel.py
echo "*/10 * * * * { test -f ~/.dashcore/dashd.pid&&cd ~/sentinel && venv/bin/python bin/sentinel.py;} >> \
~/sentinel/sentinel-cron.log 2>&1" \
|crontab -&&echo "Successfully installed cron job."
dash-cli mnsync status
dash-cli getblockcount
dash-cli masternode status
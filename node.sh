echo '7. Setting up local credentials for multichain...'
port=`sudo grep default-rpc-port ~/.multichain/chain1/params.dat | grep -oP '[0-9]{4}'`
networkport=`sudo grep default-network-port ~/.multichain/chain1/params.dat | grep -oP '[0-9]{4}'`
password=`sudo grep rpcpassword  ~/.multichain/chain1/multichain.conf | cut -d'=' -f2`
ml_host=$1
cat >~/CreditSense/bank_node/API/credentials.json <<EOF
    {
      "ml_host": "${ml_host%%:*}",
      "rpcuser": "multichainrpc",
      "rpcpasswd": "$password",
      "rpchost": "localhost",
      "rpcport": "$port",
      "chainname": "chain1",
      "mlport":"5000"
    }
EOF
echo '8. Opening ports....'
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 5000
sudo ufw allow $networkport
sudo ufw --force enable
address=`multichain-cli chain1 getaddresses | grep '"' | cut -d '"' -f2`
echo "Get 60% consensus from the network to grant admin permissions to your address $address"
echo '9. Starting flask server...'
cd ~/CreditSense/bank_node/API
python3 app.py $address &
echo '10. Starting frontend...'
sudo apt-get install -y nodejs
sudo apt-get install -y npm
cd ~/CreditSense/frontend
npm install
sudo npm start &

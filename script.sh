multichain-util create chain1 -setup-first-blocks=1 -admin-consensus-admin=0.6
sed -i -e 's/anyone-can-connect = false/anyone-can-connect = true/g' ~/.multichain/chain1/params.dat
#sed -i -e 's/anyone-can-send = false/anyone-can-send = true/g' ~/.multichain/chain1/params.dat
#sed -i -e 's/anyone-can-receive = false/aanyone-can-receive = true/g' ~/.multichain/chain1/params.dat
multichaind chain1 -daemon
echo '7. Setting up local credentials for multichain...'
port=`sudo grep default-rpc-port ~/.multichain/chain1/params.dat | grep -oP '[0-9]{4}'`
networkport=`sudo grep default-network-port ~/.multichain/chain1/params.dat | grep -oP '[0-9]{4}'`
password=`sudo grep rpcpassword  ~/.multichain/chain1/multichain.conf | cut -d'=' -f2`
cat >~/CreditSense/bank_node/API/credentials.json <<EOF
    {
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
sudo ufw allow 5000
sudo ufw allow $networkport
sudo ufw --force enable
nodeaddress=`multichain-cli chain1 getinfo | grep "nodeaddress" | cut -d '"' -f4`
multichain-cli chain1 create stream strm1 true
echo "Connect to $nodeaddress from other nodes"
sudo sed -i 's/Savoir.Savoir/Savoir/g' /usr/local/lib/python2.7/dist-packages/Savoir/__init__.py
echo '9. Starting flask server...'
cd ~/CreditSense/bank_node/API
python2 mlapi.py &

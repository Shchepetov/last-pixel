# last-pixel
*On-chain last-pixel browser game*

![Screenshot](screenshot.png)

## Installation
```console
cd ./web
python3 -m pip install -r requirements.txt
```
## Local run
🔴 **Only for test purposes!** 🔴  
⚠️ **Python ver greater or equal to 3.10 is not supported!** ⚠️
```console
python3 manage.py runserver
```
## (Optinal) Smart-contract deployment
```console
cd ./solidity
npm install --save-dev hardhat
npx hardhat run scripts/deploy.js
```
Do not forget to change network name and game address at `web/game_site/eth.py` after that.
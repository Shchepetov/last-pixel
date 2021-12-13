# last-pixel
*On-chain last-pixel browser game*

![Screenshot](screenshot.png)

## Installation
```console
cd web
python3 -m pip install -r requirements.txt
```
## Local run
**Only for test purposes!**
```console
python3 manage.py runserver
```
## (Optinal) Smart-contract deployment
```console
cd game
python3 -m pip install -r requirements.txt
brownie run scripts/deploy.py --network %network_name%
```
Do not forget to change network name at `web/game_site/eth.py` after that.
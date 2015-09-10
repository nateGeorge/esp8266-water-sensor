print('waiting 5 mins, then restarting')
tmr.delay(5*60*1000*1000) -- wait 5 minutes
node.restart()
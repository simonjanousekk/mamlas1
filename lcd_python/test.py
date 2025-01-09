from RPLCD.i2c import CharLCD
import random
import time 

t = time.time()

lcd = CharLCD(i2c_expander='PCF8574', address=0x27)
lcd.clear()
text = 'You are a robot. You are on Mars. Earth is 55 millions kilometers from you :((  '  
final = [""] * 80
interference = ""
time.sleep(2)	
# **._:*___*-__-*._:**
# ** gurl..         **
# **    guuurl      **
# **._:*___*-__-*._:**

lcd.write_string(text)


while t + 100 > time.time():
	for c in range(80):
		interference = random.choice([False, True, False, False]) 
		if interference: 
			final[c] = "*"
		else:
			final[c] = text[c]
	lcd.write_string(''.join(final))
	#print(''.join(text))
	time.sleep(0.5)


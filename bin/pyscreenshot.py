#!/usr/bin/env python

from pyvirtualdisplay import Display
from selenium import webdriver

display = Display(visible=0, size=(800, 600))
display.start()

browser = webdriver.Firefox()
browser.get('http://yellowstone:8888/Wing/Login.jsp')
browser.save_screenshot('yellowstoneLogin.png')
browser.quit()

display.stop()



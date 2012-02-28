from django.http import HttpResponseRedirect,HttpResponse,HttpResponseNotFound,Http404
from warehouse.DeviceInvTracker.models import Device,Customer
import datetime
import pyqrcode
from django.contrib.auth.decorators import login_required
from PIL import Image, ImageDraw
import ImageFont

#domain = '66.92.76.131:81' # do NOT include HTTP://
domain = 'dyio.info/' # do NOT include HTTP://
fontfile = 'DroidSans.ttf'

def formatMac(mac):
	return "{0}:{1}:{2}:{3}:{4}:{5}".format(mac[0:2],mac[2:4],mac[4:6],mac[6:8],mac[8:10],mac[10:12])

def centeredText(font,text,y,image,fill):
	draw = ImageDraw.Draw(image)
	text_size = draw.textsize(text, font=font)
	x = (image.size[0] / 2) - (text_size[0] / 2)
	draw.text((x,y),text,font=font,fill=fill)

# Create your views here.

def detail(request, mac):
	try:
		myDevice=Device.objects.get(macaddress=mac.lower())
		return HttpResponseRedirect("/warehouse/admin/DeviceInvTracker/device/%s/" % myDevice.id)
	except Device.DoesNotExist:
		return  HttpResponseNotFound("Device not found")


def getQR(request, mac):
	qr_image = pyqrcode.MakeQRImage("http://{0}/d/mac/{1}/".format(domain,mac))
	response = HttpResponse(mimetype="image/png")
	qr_image.save(response, "PNG")
	return response

def getLabel(request, mac):
	# do our database operations
	try:
		myDevice=Device.objects.get(macaddress=mac.lower())
	except Device.DoesNotExist:
		return  HttpResponseNotFound("Device not found")
	

	qr_image = pyqrcode.MakeQRImage("http://{0}/d/mac/{1}/".format(domain,mac))
	qr_small=qr_image.resize((295,295))
	im = Image.new('RGBA', (638, 295), (255, 255,255, 255)) # Create a blank image
	im.paste(qr_small, (0,0))
	draw = ImageDraw.Draw(im)
	font = ImageFont.truetype(fontfile, 40)
	font_small = ImageFont.truetype(fontfile, 25)
	font_smaller = ImageFont.truetype(fontfile, 13)
	
	devicetype=myDevice.devicetype.__unicode__().split(',')
	try:
		draw.text((295+5,25),devicetype[0].strip(),font=font, fill="black")
	except:
		draw.text((295+5,25),"",font=font, fill="black")

	try:
		draw.text((295+5,75),devicetype[1].strip(),font=font, fill="black")
	except:
		draw.text((295+5,75),"",font=font, fill="black")



	
	

	draw.text((295+5,150),'MAC:', font=font_small,fill="black")
	draw.text((295+5+100,150),formatMac(mac), font=font_small,fill="black")
	draw.text((295+5+15,250),"www.neuronrobotics.com", font=font_small,fill="black")
	#draw.text((295+5,250),"http://{0}/d/mac/{1}/".format(domain,'112233445566'), font=font_smaller,fill="black")
	#draw.text((295+5,250),"http://{0}".format(domain), font=font_smaller,fill="black")
	#draw.text((295+5,265),"/d/mac/{0}/".format('112233445566'), font=font_smaller,fill="black")
	#draw.text((295+5,250),"/d/mac/{0}/".format('112233445566'), font=font_smaller,fill="black")
	response = HttpResponse(mimetype="image/png")
	im.save(response, "PNG")
	return response

def getLabel1x15(request, mac):
	# do our database operations
	try:
		myDevice=Device.objects.get(macaddress=mac.lower())
	except Device.DoesNotExist:
		return  HttpResponseNotFound("Device not found")
	

	qr_image = pyqrcode.MakeQRImage("http://{0}/d/mac/{1}/".format(domain,mac)) # geterate the QR
	qr_small=qr_image.resize((300,300)) # scale QR to our image
	im = Image.new('RGBA', (300, 463), (255, 255,255, 255)) # Create a blank label
	im.paste(qr_small, (0,0)) # paste QR onto label
	
	#set up text-drawing
	draw = ImageDraw.Draw(im) 
	font = ImageFont.truetype(fontfile, 30)
	font_small = ImageFont.truetype(fontfile, 25)
	font_smaller = ImageFont.truetype(fontfile, 18)
	
	# Process device name.
	
	try:
		centeredText(font=font,text=myDevice.devicetype.maker,y=310,image=im,fill="black")
		#draw.text((0,350),devicetype[0].strip(),font=font, fill="black")
	except:
		centeredText(font=font,text="",y=310,image=im,fill="black")
		#draw.text((295+5,25),"",font=font, fill="black")

	try:
		#draw.text((295+5,75),devicetype[1].strip(),font=font, fill="black")
		centeredText(font=font,text="{0} REV.{1}".format(myDevice.devicetype.model,myDevice.devicetype.revision),y=345,image=im,fill="black")
	except:
		draw.text((295+5,75),"",font=font, fill="black")



	
	
	centeredText(font=font_small,text="MAC: "+formatMac(mac),y=395,image=im,fill="black")
	centeredText(font=font_smaller,text="www.neuronrobotics.com",y=440,image=im,fill="black")

	response = HttpResponse(mimetype="image/png")
	im.save(response, "PNG")
	return response



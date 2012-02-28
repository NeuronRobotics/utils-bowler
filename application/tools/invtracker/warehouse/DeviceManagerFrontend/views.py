# Create your views here.
from django.template import Context, loader
from django import forms
from django.shortcuts import render_to_response
from django.http import HttpResponse,HttpResponseRedirect
from django.contrib.auth.decorators import *
#import our models
from warehouse.DeviceInvTracker.models import Device,Customer,DeviceType,WorkEvent,WorkType


	
class DeviceLookupForm(forms.Form):
	address = forms.CharField(max_length=17)

class WorkTypeSelectionForm(forms.Form):
	worktype = forms.ModelChoiceField(queryset=WorkType.objects.all())
	comment = forms.CharField(widget=forms.Textarea)

# look up a device by MAC and show it's device page
@login_required
def deviceLookup(request):
	if request.method == 'POST':
		# is the form valid?
		form = DeviceLookupForm(request.POST)
		if form.is_valid():
			#look up device

			#check to see if user can view device

			#redirect to infopage
			macaddress = form.cleaned_data['address']
			return HttpResponseRedirect('/manager/device/{0}/info'.format(macaddress))
		else:
			#no, its not. return the form
			form = DeviceLookupForm()
		return render_to_response('deviceLookup.html', {
			'form': form,
		})
	else:
		# It's a GET request. Send them the form.
		form = DeviceLookupForm()
		return render_to_response('deviceLookup.html', {
			'form': form,
		})

# device info page
@login_required
def deviceInfo(request, mac):
	#look up the device	
	try:
		device = Device.objects.get(macaddress=mac)
		user = request.user
		for member in device.owner.people.all():
			if member==user:
				return HttpResponse("Here is your Device..")
		# that device is not thiers
		return HttpResponse("Device not found. It may be missing or not registered to you")
	except Device.DoesNotExist:
		return HttpResponse("Device not found. It may be missing or not registered to you")

@login_required
def deviceTriage(request, mac):
	try:
		device = Device.objects.get(macaddress=mac)
		user = request.user
		if device.ownedbyuser(user):
			#good, they own it
			#Is this a POST or a GET?
			if request.method == 'POST':
				form = WorkTypeSelectionForm(request.post)
				# they're submitting
				return HttpResponse("unimplemented")
			else:
				form = WorkTypeSelectionForm()
				return render_to_response('deviceTriage.html', {
					'form': form,
				})
				# send the form
		else:		
			#they don't own the device
			return HttpResponse("Device not found. It may be missing or not registered to you")
	except Device.DoesNotExist:
		return HttpResponse("Device not found. It may be missing or not registered to you")










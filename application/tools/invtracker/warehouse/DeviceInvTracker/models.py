from django.db import models
from django.contrib.auth.models import User,Group
import datetime




STATE_CHOICES = (
	(u'good',"Operational"),
	(u'broken',"User Damage"),
	(u'defective',"Defective"),
	(u'unknown',"Unknown"),
)
# Create your models here.





class Customer(models.Model):
	#firstname  = models.CharField(max_length=50, verbose_name='First Name')
	#lastname  = models.CharField(max_length=50, verbose_name='Last Name')
	name = models.CharField(max_length=200, verbose_name='Customer Name',null=True,blank=True)
	#email = models.EmailField(max_length=200, verbose_name='E-Mail',null=True,blank=True)
	#phone = models.CharField(max_length=200, verbose_name='Phone Number',null=True,blank=True)
	pub_date = models.DateTimeField(verbose_name='Registration Date')
	people = models.ManyToManyField(User)
	def __unicode__(self):
			return self.name



class DeviceType(models.Model):
	maker = models.CharField(max_length=50, verbose_name='Maker')
	model = models.CharField(max_length=50, verbose_name='Model')
	revision = models.CharField(max_length=50, verbose_name='Revision')
	def __unicode__(self):
		return "{0} {1}, REV.{2}".format(self.maker,self.model,self.revision)

class Device(models.Model):
	macaddress = models.CharField(max_length=12,unique=True)
	devicetype = models.ForeignKey(DeviceType,verbose_name='Device Type')
	owner = models.ForeignKey(Customer)
	state = models.CharField(max_length=50,choices=STATE_CHOICES)
	entry_date = models.DateTimeField(verbose_name='Entry Date')
	notes=models.CharField(max_length=500, verbose_name='Device Notes',null=True,blank=True)
	def ownedbyuser(self,user):
		for member in self.owner.people.all():
			if member==user:
				return True
		return False
	def __unicode__(self):
		return "Device: "+self.macaddress

class WorkType(models.Model):
	worktype  = models.CharField(max_length=50, verbose_name='Work Type')
	applicable_devices = models.ManyToManyField(DeviceType)
	viewers = models.ManyToManyField(Group, related_name="users_who_can_see_work")
	performers = models.ManyToManyField(Group, related_name="users_who_can_do_work") 
	
	def __unicode__(self):
		return self.worktype

class WorkEvent(models.Model):
	device = models.ForeignKey(Device, verbose_name='Device')
	tech=models.ForeignKey(User, verbose_name='Technician')
	notes=models.CharField(max_length=500, verbose_name='Work Event Notes',null=True,blank=True)
	work_type=models.ForeignKey(WorkType, verbose_name='Repair Type')
	entry_date = models.DateTimeField(verbose_name='Work Date', default=datetime.datetime.now)



	


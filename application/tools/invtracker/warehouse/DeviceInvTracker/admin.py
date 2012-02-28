from warehouse.DeviceInvTracker.models import Device,Customer,DeviceType,WorkEvent,WorkType
from django.contrib import admin

class DeviceInline(admin.TabularInline):
	readonly_fields=['macaddress','devicetype','owner','state','entry_date','notes']
	model=Device
	extra=0

class WorkEventInline(admin.TabularInline):
	model=WorkEvent
	#readonly_fields=['device','tech','notes','work_type']
	readonly_fields=['entry_date']
	extra=0

class CustomerAdmin(admin.ModelAdmin):
	inlines=[DeviceInline]

class DeviceAdmin(admin.ModelAdmin):
	inlines=[WorkEventInline]

		
		

admin.site.register(Device, DeviceAdmin)
admin.site.register(Customer,CustomerAdmin)
admin.site.register(DeviceType)
admin.site.register(WorkEvent)
admin.site.register(WorkType)

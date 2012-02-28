from django.conf.urls.defaults import patterns, include, url
import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
	url(r'^d/mac/(?P<mac>\w+)/$', 'DeviceInvTracker.views.detail'),
	url(r'^qr/mac/(?P<mac>\w+)/qr.png$', 'DeviceInvTracker.views.getQR'),
	url(r'^qr/mac/(?P<mac>\w+)/label.png$', 'DeviceInvTracker.views.getLabel'),
	url(r'^qr/mac/(?P<mac>\w+)/label1x15.png$', 'DeviceInvTracker.views.getLabel1x15'),
    # Examples:
    # url(r'^$', 'warehouse.views.home', name='home'),
    # url(r'^warehouse/', include('warehouse.foo.urls')),
	url(r'^manager/d/lookup','DeviceManagerFrontend.views.deviceLookup'),
	url(r'^manager/device/(?P<mac>\w+)/info','DeviceManagerFrontend.views.deviceInfo'),
	url(r'^manager/device/(?P<mac>\w+)/triage','DeviceManagerFrontend.views.deviceTriage'),
    # Uncomment the admin/doc line below to enable admin documentation:
	url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
	url(r'^admin/', include(admin.site.urls)),
        (r'^grappelli/', include('grappelli.urls')),
	(r'^static/(?P<path>.*)$', 'django.views.static.serve',{'document_root': '/home/acamilo/Django/device-warehouse/warehouse/sitestatic'}),
	
)

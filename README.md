# Paas Rproxy HA #

##Description##


**Paas Rproxy HA** is an HA front load balancer/reverse proxy for Paas solution like Openshift Origin by Redhat.

In the actual release, it is designed to operate with Openshift Origin through the `paas-appli-updater` that listen Stomp update messages from Openshift Origin.

![](https://raw.github.com/worldline/paas-appli-updater/master/paas-ha.jpg)


The `paas-appli-updater` send Mcollective messages to the `paas-rproxy-agent` to update the rproxy/load balancer (Nginx) configuration.

As you can see, it's not an intrusive solution in the Paas solution of Redhat.

The **High Availability** of the solution is assumed by Keepalived in an active/active configuration.

The `paas-rproxy-conf`package performs initial configuration of components used on the fronts reverses proxies/load balancers.
It covers the Activemq, Mcollective, Nginx, Keepalived `paas-rproxy-agent` configurations.


##Installation##


Perform a yum install of the `paas-apppli-updater` package on the Openshift Origin Broker to install it ant it's dependancies like the `paas-libs` package.

The installation patches the existing Activemq configuration to replicate the appropriate queues and topics used by **Paas Rproxy HA**.

Modify the configuration file of the `paas-appli-updater` in the /etc/paas directory to follow your needs.

Perform a yum install of the `paas-rproxy-agent` on a fresh Centos 6 install on new nodes to install it with its dependancies.

Perform a service paas-ConfigProxy start on the broker to process.
Every time you modify the lifecycle of an application, the `paas-appli-updater` updates the configuration of the front reverses proxies/load balancers.

They route network flows to Web gears according to the Openshift Origin vocabulary, so the **Paas Rproxy HA** bypass Haproxy gears in the cases of scalables applications.

###TO DO###
_2013 October-10_

Complete the configuration package to update all the configurations of the components used by the **Paas Rproxy HA**

Modify the ActiveMq listening topics and messages content interpretation when Redhat will release its SPI.

Publish a detailled installation procedure and Manual Handbook.

####Note####
Because we're configuring a users DNS to resolve all the applications Urls in the Openshift Origin DNS zone to point to the service IP load balanced by the front reverses proxies/load balancers, you need to apply our patch of Openshift Origin to reference the ssh urls published by Openshift Origin as IP addresses instead of hostnames.
This allows the user to connect to the gears of its applications.
# encoding: utf-8
require 'erb'
require 'fileutils'
require 'resolv'
require 'socket'
require 'rubygems'
$Prefixconf = "/etc/nginx/conf.d"
$PrefixAgent = "/usr/libexec/mcollective/mcollective/agent"
$RproxyCmd = "/usr/local/paas/bin/rproxy"

module MCollective
	module Agent
		class Rproxy<RPC::Agent

			def backupFile(filename)
				if File.exist?(filename)
					FileUtils.cp(filename, "#{filename}.bak")
				end
			end

			def restoreFile(filename)
				if File.exist?(filename)
					FileUtils.mv("#{filename}.bak", filename)
				end
			end

			def deleteFile(filename)
				if File.exist?(filename)
					FileUtils.rm_f(filename)
				end
			end

			action "conf" do
				Log.debug("Rproxy conf:Parameters #{request[:appname]} , #{request[:domainname]}, #{request[:args]}, #{request[:appalias]}")
				appname = request[:appname]
				validate :appname, /\A[a-zA-Z0-9\.\-]+\z/
				validate :appname, :shellsafe

				domainname = request[:domainname]
				validate :domainname, /\A[a-zA-Z0-9\.\-]+\z/
				validate :domainname, :shellsafe

				aliases=[]
				if request[:appalias]
					appalias = request[:appalias]
					validate :appalias, /\A[a-zA-Z0-9\.\-\s]+\z/
					validate :appalias, :shellsafe
					aliases = appalias.split
				end

				args = request[:args]
				validate :args, /\A[\d\.\s:"]+\z/
				validate :args, :shellsafe

				arguments = []
				arguments = args.split

				urlName = String.new("#{appname}.#{domainname}")

				begin
					# Saving previous confs
					# As a semaphore we could test the presence of .bak in case of simultaneous executions
					backupFile("#{$Prefixconf}/#{urlName}-upstream.conf")
					backupFile("#{$Prefixconf}/#{urlName}-http.conf")
					backupFile("#{$Prefixconf}/#{urlName}-https.conf")
				rescue Exception => e
					 Log.debug("#{e.message}")
					 Log.debug("#{e.backtrace.inspect}")
					 reply[:exitcode] = "Error: #{e.message}"
				else
				# We continue only in case of successful save
					begin
						if args.eql?(" ")== false
							template = "upstream"
							File.open( "#{$PrefixAgent}/rproxy.tmpl", 'r') do |fh|
								erb = ERB.new( fh.read )
								File.open("#{$Prefixconf}/#{urlName}-upstream.conf", 'w') do |f|
									f.write erb.result( binding )
								end
							end
						end
						for template in "http https".split do
							File.open( "#{$PrefixAgent}/rproxy.tmpl", 'r') do |fh|
								erb = ERB.new( fh.read )
								File.open("#{$Prefixconf}/#{urlName}-#{template}.conf", 'w') do |f|
									f.write erb.result( binding )
								end
							end
						end
						`#{$RproxyCmd} -t`
						if $?.to_i != 0
							Log.debug("Rproxy:Conf #{urlName} NOK ")
							deleteFile("#{$Prefixconf}/#{urlName}-upstream.conf")
							deleteFile("#{$Prefixconf}/#{urlName}-http.conf")
							deleteFile("#{$Prefixconf}/#{urlName}-https.conf")
							restoreFile("#{$Prefixconf}/#{urlName}-upstream.conf")
							restoreFile("#{$Prefixconf}/#{urlName}-http.conf")
							restoreFile("#{$Prefixconf}/#{urlName}-https.conf")
						else
							Log.debug("Rproxy:Conf #{urlName} OK ")
							deleteFile("#{$Prefixconf}/#{urlName}-upstream.conf.bak")
							deleteFile("#{$Prefixconf}/#{urlName}-http.conf.bak")
							deleteFile("#{$Prefixconf}/#{urlName}-https.conf.bak")
							`#{$RproxyCmd} -r`
						end
						reply[:exitcode] = "OK"
					rescue Exception => ee
						deleteFile("#{$Prefixconf}/#{urlName}-upstream.conf.bak")
						deleteFile("#{$Prefixconf}/#{urlName}-http.conf.bak")
						deleteFile("#{$Prefixconf}/#{urlName}-https.conf.bak")
						Log.debug(ee.message)
						Log.debug("#{ee.backtrace.inspect}")
						reply[:exitcode] = "Error: #{ee.message}"
					end
				end
			end

			action "unconfigure" do
				Log.debug("Rproxy unconfigure:Parameters #{request[:appname]}, #{request[:domainname]}")

				appname = request[:appname]
				validate :appname, /\A[a-zA-Z0-9\.\-]+\z/
				validate :appname, :shellsafe

				domainname = request[:domainname]
				validate :domainname, /\A[a-zA-Z0-9\.\-]+\z/
				validate :domainname, :shellsafe

				urlName = String.new("#{appname}.#{domainname}")
				begin
					# Saving previous confs
					# As a semaphore we could test the presence of .bak in case of simultaneous executions
					backupFile("#{$Prefixconf}/#{urlName}-https.conf")
					backupFile("#{$Prefixconf}/#{urlName}-http.conf")
					backupFile("#{$Prefixconf}/#{urlName}-upstream.conf")
				rescue Exception => e
					Log.debug(e.message)
					Log.debug("#{e.backtrace.inspect}")
					reply[:exitcode] = "Erreur: #{e.message}"
				else
					# We continue only in case of successful save
					begin
						deleteFile("#{$Prefixconf}/#{urlName}-http.conf")
						deleteFile("#{$Prefixconf}/#{urlName}-https.conf")
						deleteFile("#{$Prefixconf}/#{urlName}-upstream.conf")
						`#{$RproxyCmd} -t`
						if $?.to_i != 0
							Log.debug("Rproxy:unconfigure #{urlName} NOK ")
							restoreFile("#{$Prefixconf}/#{urlName}-upstream.conf")
							restoreFile("#{$Prefixconf}/#{urlName}-http.conf")
							restoreFile("#{$Prefixconf}/#{urlName}-https.conf")
						else
							Log.debug("Rproxy:unconfigure #{urlName} OK ")
							deleteFile("#{$Prefixconf}/#{urlName}-http.conf.bak")
							deleteFile("#{$Prefixconf}/#{urlName}-https.conf.bak")
							deleteFile("#{$Prefixconf}/#{urlName}-upstream.conf.bak")
							`#{$RproxyCmd} -r`
						end
						reply[:exitcode] = "OK"
					rescue Exception => ee
						deleteFile("#{$Prefixconf}/#{urlName}-http.conf.bak")
						deleteFile("#{$Prefixconf}/#{urlName}-https.conf.bak")
						deleteFile("#{$Prefixconf}/#{urlName}-upstream.conf.bak")
						Log.debug("#{ee.message}")
						Log.debug("#{ee.backtrace.inspect}")
						reply[:exitcode] = "Erreur: #{ee.message}"
					end
				end
			end

		end
	end
end

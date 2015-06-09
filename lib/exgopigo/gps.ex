defmodule ExGoPiGo.GPS do
	require Logger

	# The GPS module used is a Grove GPS module http://www.seeedstudio.com/depot/Grove-GPS-p-959.html
	# Refer to SIM28 NMEA spec file http://www.seeedstudio.com/wiki/images/a/a0/SIM28_DATA_File.zip

	def init() do
		:serial.start([speed: 9600, open: :erlang.bitstring_to_list("/dev/ttyAMA0")])
	end

	def location(pid) do
		[_, lat_str, lat_ns, long_str, long_ew, _, _, _] = read_data(pid)

		lat = String.to_float(lat_str) |> negate_if_needed(lat_ns) |> decimal_degrees
		long = String.to_float(long_str) |> negate_if_needed(long_ew) |> decimal_degrees

		{ lat, long }
	end

	defp negate_if_needed(long_or_lat, ns_or_ew) do
		if ns_or_ew == "S" or ns_or_ew == "W" do
			-long_or_lat
		else
			long_or_lat
		end
	end

	defp read_data(pid) do
		receive do
			# GGA data , packet 1, has all the data we need
			{:data, "$GPGGA" <> rest} -> 
				line = readline(pid, "$GPGGA" <> rest)
				Logger.info line
				[_, time, lat_string, lat_ns, long_str, long_ew, fix_status, satellite_count, altitude, _, _, _, _, _, _] = String.split(line, ",")
				Logger.info "Time: #{time}, Fix status: #{fix_status}, Sats in view: #{satellite_count}, Altitude: #{altitude}, Lat: #{lat_string} #{lat_ns}, Long: #{long_str} #{long_ew}"
				[time, lat_string, lat_ns, long_str, long_ew, fix_status, satellite_count, altitude]

			_ -> 
				:timer.sleep(100)
				read_data(pid)
		end
	end

	defp readline(pid, line) do
		receive do
			{:data, string} -> 
				if String.match?(string, ~r/.*\r\n.*/) do
					[s | _] = String.split(string, "\r\n")
					line <> s
				else
					readline(pid, line <> string)
				end
		end
	end

	# Convert raw degrees from GPS to decimal decrees
	# which can be pasted right into Google Maps.
	defp decimal_degrees(raw_degrees) do
		# Convert to decimal degrees
		degrees = trunc(raw_degrees / 100)
		fraction = (raw_degrees / 100 - degrees) * 100 / 60
		degrees + fraction
	end

end

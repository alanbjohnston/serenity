#1/bin/sh

sudo modprobe snd-aloop

#if [ ! -d "./direwolf.conf" ]; then

FILE=direwolf.conf
if [ ! -f "$FILE" ]; then

  wget https://raw.githubusercontent.com/alanbjohnston/CubeSatSim/FIAB-v3/groundstation/direwolf.conf 

fi

FILE=direwolf-4800.conf
if [ ! -f "$FILE" ]; then

  wget https://raw.githubusercontent.com/alanbjohnston/CubeSatSim/FIAB-v3/groundstation/direwolf-4800.conf 

fi



sudo killall -9 rtl_fm &>/dev/null
sudo killall -9 direwolf &>/dev/null

sleep 5

echo

echo "Choose the number for the type of decoding:"
echo
echo "1. APRS US 2m (144.390 MHz)"
echo "2. ISS APRS (145.825 MHz"
echo "3. APRS on some other frequency"
echo "4. Serenity CubeSat 4800 bps (437.1 MHz)"
echo "5. Test Serenity CubeSat decoding with WAV file"

echo

read -r choice


if [ "$choice" = "1" ]; then
  echo

  frequency=144390000
  
  echo

  echo "Note that the 'Tuned to' frequency will be different from the chosen frequency due to the way SDRs work."

  echo

  echo -e "Auto decoding APRS packets on $frequency Hz"

  direwolf -r 48000 -t 0 &

  sleep 5

  value='aplay -l | grep "Loopback"'
  echo "$value" > /dev/null
  set -- $value

# rtl_fm -M fm -f $frequency -s 48k | tee >(aplay -D hw:${2:0:1},0,0 -r 48000 -t raw -f S16_LE -c 1) | aplay -D hw:0,0 -r 48000 -t raw -f S16_LE -c 1
#rtl_fm -M fm -f $frequency -s 48k | tee >(aplay -D hw:3,0,0 -r 48000 -t raw -f S16_LE -c 1) | aplay -D hw:0,0 -r 48000 -t raw -f S16_LE -c 1
rtl_fm -M fm -f $frequency -s 48k | tee >(aplay -D hw:3,0,0 -r 48000 -t raw -f S16_LE -c 1) | aplay -D hw:0,0 -r 48000 -t raw -f S16_LE -c 1
 
  sleep 5

elif [ "$choice" = "2" ]; then
  echo

  echo "CubicSDR will load in about 10 sceonds."

  nohup CubicSDR </dev/null >/dev/null 2>&1 & 

  echo

  echo "When CubicSDR opens, select Generic RTL2832 device then click Start to begin."

  echo

  echo "Then select File/Session/Open Session then load cubicsdr-iss-direwolf.xml then Open."
  echo "Note that you won't get packets unless the ISS is passing over and the radio is in APRS digipeater mode."
  echo 

  echo "Hit the Return key when you have done this in CubicSDR and Direwolf will start"

  read input

  direwolf -c direwolf.conf -r 48000 -t 0

elif [ "$choice" = "3" ]; then
  echo

  echo "CubicSDR will load in about 10 sceonds."

  nohup CubicSDR </dev/null >/dev/null 2>&1 & 

  echo

  echo "When CubicSDR opens, select Generic RTL2832 device then click Start to begin."

  echo

  echo "Then select File/Session/Open Session then load cubicsdr-aprs-direwolf.xml then Open."
  echo "Then tune the CubicSDR frequency to the one you want to decode."

  echo 

  echo "Hit the Return key when you have done this in CubicSDR and Direwolf will start"

  read input

  direwolf -c direwolf.conf -r 48000 -t 0

elif [ "$choice" = "4" ]; then
  echo

  echo "CubicSDR will load in about 10 sceonds."

  nohup CubicSDR </dev/null >/dev/null 2>&1 & 

  echo

  echo "When CubicSDR opens, select Generic RTL2832 device then click Start to begin."

  echo

  echo "Then select File/Session/Open Session then load cubicsdr-serenity-direwolf.xml then Open."
  echo "Note that you won't get packets unless the Serenity CubeSat is passing over and is beaconing."

  echo 

  echo "Hit the Return key when you have done this in CubicSDR and Direwolf will start"

  read input

  direwolf -c direwolf-4800.conf -r 48000 -t 0

elif [ "$choice" = "5" ]; then

  echo "A recorded WAV file will play and you should see about 4 packets decoded"

  echo 

#  echo "Hit the Return key when you have done this in CubicSDR and Direwolf will start"

#  read input

  aplay -D hw:0,0 ~/Recordings/437.098_2021-08-28_10-41-34.wav &

  aplay -D hw:3,0,0 ~/Recordings/437.098_2021-08-28_10-41-34.wav &

  timeout 30 direwolf -c direwolf-4800.conf -r 48000 -t 0
  
  echo
  
  echo "Test complete.  This window will close in 10 seconds."
  
  sleep 5
  
fi

sleep 5


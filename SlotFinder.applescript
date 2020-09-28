
set found_slot to false
set slot_page_keyword to "Select a delivery address"
-- set the slot_site_url to your specific url in the checkout page of amazon
set slot_site_url to "https://www.amazon.com/gp/buy/shipoptionselect/handlers/display.html?hasWorkingJavascript=1"
set no_slot_keyword to "No doorstep delivery windows are available"
set is_first_run to true

-- create new empty window, with one empty tab
tell application "Safari"
	make new document
	delay 0.5 -- wait for new window to open
	-- instead of creating a new tab in your current window, this creates a window and 'hides it by minimizing it. 
	set amzn_win_id to id of front window
end tell

repeat while found_slot is false
	-- load the delivery slot page
	tell application "Safari"
		-- opens in a new tab every time instead of just using open url request, which would prompt "Are you sure you want to send a form again?" and prevent this from running neatly in the background
		tell window id amzn_win_id
			make new tab with properties {URL:slot_site_url}
			set current tab to last tab
		end tell
		if is_first_run is true then
			-- minimizes window on the first iteration so it can run quietly in background
			set miniaturized of window id amzn_win_id to true
			set is_first_run to false
		end if
		
		-- wait for the page to load
		delay 20
		
		-- get the text on the page
		set siteText to (text of last tab of window id amzn_win_id) as string
	end tell
	
	-- PROCESS PAGE CONTENTS:
	
	-- no delivery slots available
	if siteText contains no_slot_keyword then
		-- closes the tab since no slot was found
		tell application "Safari"
			close (last tab of window id amzn_win_id)
		end tell
		
		log "no slots found"
		
		-- delay so you don't spam Amazon's site
		delay 10
		
	else if siteText does not contain no_slot_keyword then
		-- landed on delivery slot page and delivery slot selection drop down appears aka. slot found!
		display notification "Found delivery slot!" with title "Amazon" sound name "Sosumi"
		say "Success: Delivery slot found"
		set found_slot to true
		
		tell application "Safari"
			-- bring window to front
			set miniaturized of window id amzn_win_id to false
			-- wait for window to open
			delay 1
			-- maximize window so delivery slots are clearly visible
			-- this might be useful later on if I want to have it take a screenshot as proof of delivery slots found
			tell application "System Events"
				tell application "Finder" to get the bounds of the window of the desktop
				tell application "Safari" to set the bounds of the front window to ¬
					{0, 22, (3rd item of the result), (4th item of the result)}
			end tell
		end tell
		set message to "Slot Found on PrimeNow"
		tell application "Messages"
			-- this sends 3 messages to phone type + country code then phone number with area code
			-- this sends a message from your messanger app, so you must be signed in on messanges on your mac
			-- you'll want to send a message to a different number you might have (burner number) so that you get notified of message
			send message to buddy "enter phone number here" of service "SMS"
			send message to buddy "+11234567890" of service "SMS"
			send message to buddy "+11234567890" of service "SMS"
		end tell
		delay 1
		
	else
		say "Error on page"
		set found_slot to true
		
	end if
end repeat


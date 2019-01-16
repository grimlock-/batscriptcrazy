//Timeout Structure
	function timeoutStructure() {
		var timeouts = new Array();
		var pausedTimeouts = new Array();
		
		this.createTimeout = function(callback, delay) {
			var tmpStruct = {};
			tmpStruct.TID = setTimeout(callback, delay);
			tmpStruct.startTime = Date.now();
			tmpStruct.triggerTime = tmpStruct.startTime + delay;
			tmpStruct.remainingTime = delay;
			tmpStruct.callback = callback;
			timeouts.push(tmpStruct);
		}
		this.removeTimeout = function(timeoutFunction) {
			for(var i = 0; i < timeouts.length; i++) {
				if(timeouts[i].callback == timeoutFunction) {
					clearTimeout(timeouts[i].TID);
					timeouts.splice(i, 1);
					return 0;
				}
			}
			if(typeof console != "undefined") {
				console.log("Timeout not found");
			}
			return -1;
		}
		/*Arg: callback function to be searched for
		Return: Element in the array containing the provided function or a string if unable to find the function
		Search the active timeouts array for an element containing the provided function as a callback*/
		this.getTimeout = function(findme) {
			if(timeouts.length > 0) {
				if(typeof findme == "number") {
					if(findme >= timeouts.length)
						return "Give a number smaller than " + timeouts.length;
					else
						return timeouts[findme];
				} else if(typeof findme == "function") {
					for(var i = 0; i < timeouts.length; i++) {
						if(timeouts[i].callback == findme)
							return timeouts[i];
					}
					return "Timeout not found";
				}
			} else return "No timeouts right now, try again later";
		}
		/*Arg: function object to be found
		Return: the given function's current position in the array or -1 if unable to find the function
		Search the active timeouts array for a specific function*/
		this.getTimeoutIndex = function(findme) {
			for(var i = 0; i < timeouts.length; i++) {
				if(timeouts[i].callback == timeoutFunction)
					return i;
			}
			return -1;
		}
		this.getPausedTimeout = function(findme) {
			if(pausedTimeouts.length > 0) {
				if(typeof findme == "number") {
					if(findme >= pausedTimeouts.length)
						return "Give a number smaller than " + pausedTimeouts.length;
					else
						return pausedTimeouts[findme];
				} else if(typeof findme == "function") {
					for(var i = 0; i < pausedTimeouts.length; i++) {
						if(pausedTimeouts[i].callback == timeoutFunction)
							return pausedTimeouts[i];
					}
				}
			} else return "No paused timeouts right now, try again later";
		}
		this.getPausedTimeoutIndex = function(findme) {
			for(var i = 0; i < pausedTimeouts.length; i++) {
				if(pausedTimeouts[i].callback == findme)
					return pausedTimeouts[i];
			}
			return -1;
		}
		//TODO - write a function to pause a specific timeout
		this.clearAll = function() {
			if(timeouts.length > 0) {
				while(0 < timeouts.length) {
					clearTimeout(timeouts[0].TID);
					timeouts.splice(0, 1);
				}
			}
		}
		this.pauseAll = function() {
			if(timeouts.length > 0) {
				while(0 < timeouts.length) {
					clearTimeout(timeouts[0].TID);
					timeouts[0].remainingTime = timeouts[0].triggerTime - Date.now();
					pausedTimeouts.push(timeouts[0]);
					timeouts.splice(0, 1);
				}
			}
		}
		this.resumeAll = function() {
			while(0 < pausedTimeouts.length) {
				pausedTimeouts[0].TID = setTimeout(pausedTimeouts[0].callback, pausedTimeouts[0].remainingTime);
				pausedTimeouts[0].startTime = Date.now();
				timeouts.push(pausedTimeouts[0]);
				pausedTimeouts.splice(0, 1);
			}
		}
	}
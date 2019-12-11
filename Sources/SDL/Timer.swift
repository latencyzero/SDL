//
//  File.swift
//  
//
//  Created by Rick Mann on 2019-12-10.
//

import CSDL2


/**
	A repeating timer
*/

public
class
SDLTimer
{
	public typealias Block = (_ inTimer: SDLTimer) -> ()
	
	
	public
	init(interval inInterval: UInt, block inBlock: @escaping Block)
	{
		self.timerID = 0
		self.block = inBlock
		
		let ud = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
		self.timerID = SDL_AddTimer(Uint32(inInterval),
		{ (inInterval, inUserData) -> Uint32 in
			
			//	Wrap the timer callback in an event to keep things
			//	happening on the main queue…
			
			let ue = SDL_UserEvent(type: SDLUserTimerEvent.rawValue, timestamp: 0, windowID: 0, code: 0, data1: inUserData, data2: nil)
			var event = SDL_Event()
			event.user = ue
			SDL_PushEvent(&event)
			
			return inInterval
		},
		ud)
	}
	
	deinit
	{
		SDL_RemoveTimer(self.timerID)
	}
	
	public
	class
	func
	handle(userEvent inEvent: SDL_UserEvent)
	{
		let this = Unmanaged<SDLTimer>.fromOpaque(inEvent.data1!).takeUnretainedValue()
		this.block(this)
	}
	
	var		timerID:	SDL_TimerID
	var		block:		Block
}

public var SDLUserTimerEvent = SDL_EventType(rawValue: SDL_RegisterEvents(1))

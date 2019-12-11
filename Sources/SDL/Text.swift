//
//  Text.swift
//  
//
//  Created by Rick Mann on 2019-12-10.
//

import CSDL2
import CSDL2TTF




public
class
SDLFont
{
	public
	init(path inPath: String, size inSize: Int)
		throws
	{
		let ip = TTF_OpenFont(inPath, Int32(inSize))
		self.internalPointer = try ip.sdlThrow(type: type(of: self))
	}
	
	deinit
	{
		TTF_CloseFont(self.internalPointer)
	}
	
	internal let internalPointer: OpaquePointer
}

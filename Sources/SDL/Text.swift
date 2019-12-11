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
	
	public
	init(path inPath: String, size inSize: Int, index inIndex: Int)
		throws
	{
		let ip = TTF_OpenFontIndex(inPath, Int32(inSize), inIndex)
		self.internalPointer = try ip.sdlThrow(type: type(of: self))
	}
	
	deinit
	{
		TTF_CloseFont(self.internalPointer)
	}
	
	public
	var
	familyName: String
	{
		get
		{
			let v = TTF_FontFaceFamilyName(self.internalPointer)
			return String(cString: v!)
		}
	}
	
	public
	var
	styleName: String
	{
		get
		{
			let v = TTF_FontFaceStyleName(self.internalPointer)
			return String(cString: v!)
		}
	}
	
	public
	var
	faceCount: Int
	{
		get
		{
			return TTF_FontFaces(self.internalPointer)
		}
	}
	

	internal let internalPointer: OpaquePointer
}

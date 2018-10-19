//
//  Renderer.swift
//  SDL
//
//  Created by Alsey Coleman Miller on 6/6/17.
//

import CSDL2

public final class Renderer {
    
    // MARK: - Properties
    
    internal let internalPointer: OpaquePointer
    
    // MARK: - Initialization
    
    deinit {
        SDL_DestroyRenderer(internalPointer)
    }
    
    /// Create a 2D rendering context for a window.
    public init(window: Window, driver: Driver = .default, options: BitMaskOptionSet<Renderer.Option> = []) throws {
        
        let internalPointer = SDL_CreateRenderer(window.internalPointer, Int32(driver.index), options.rawValue)
        self.internalPointer = try internalPointer.sdlThrow()
    }
    
    /// The color used for drawing operations (Rect, Line and Clear).
    public func drawColor() throws -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        
        var red: UInt8 = 0
        var green: UInt8 = 0
        var blue: UInt8 = 0
        var alpha: UInt8 = 0
        
        try SDL_GetRenderDrawColor(internalPointer, &red, &green, &blue, &alpha).sdlThrow()
        
        return (red, green, blue, alpha)
    }
    
    public func setDrawColor(_ newValue: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)) throws {
        
         try SDL_SetRenderDrawColor(internalPointer, newValue.red, newValue.green, newValue.blue, newValue.alpha).sdlThrow()
    }
    
    /// Current rendering target texture.
    public private(set) var target: SDL.Texture?
    
    public func setTarget(_ newValue: SDL.Texture?) throws {
        
        try SDL_SetRenderTarget(internalPointer, target?.internalPointer).sdlThrow()
        
        // hold reference
        self.target = newValue
    }
    
    /// The blend mode used for drawing operations (Fill and Line).
    public var drawBlendMode: SDL.BlendMode {
        
        get {
            
            var value = SDL_BlendMode(0)
            
            SDL_GetRenderDrawBlendMode(internalPointer, &value)
            
            return SDL.BlendMode(value)
        }
        
        set { SDL_SetRenderDrawBlendMode(internalPointer, SDL_BlendMode(newValue)) }
    }
    
    // MARK: - Methods
    
    /// Clear the current rendering target with the drawing color
    /// This function clears the entire rendering target, ignoring the viewport.
    @discardableResult
    public func clear() -> Bool {
        
        return SDL_RenderClear(internalPointer) >= 0
    }
    
    /// Update the screen with rendering performed.
    public func present() {
        
        SDL_RenderPresent(internalPointer)
    }
    
    /// Copy a portion of the texture to the current rendering target.
    @discardableResult
    public func copy(_ texture: SDL.Texture, source: SDL_Rect? = nil, destination: SDL_Rect? = nil) -> Bool {
        
        let sourcePointer: UnsafeMutablePointer<SDL_Rect>?
        
        defer { sourcePointer?.deallocate() }
        
        if let rect = source {
            
            sourcePointer = UnsafeMutablePointer.allocate(capacity: 1)
            
            sourcePointer?.pointee = rect
            
        } else {
            
            sourcePointer = nil
        }
        
        let destinationPointer: UnsafeMutablePointer<SDL_Rect>?
        
        defer { destinationPointer?.deallocate() }
        
        if let rect = destination {
            
            destinationPointer = UnsafeMutablePointer.allocate(capacity: 1)
            
            destinationPointer?.pointee = rect
            
        } else {
            
            destinationPointer = nil
        }
        
        return SDL_RenderCopy(internalPointer, texture.internalPointer, sourcePointer, destinationPointer) >= 0
    }
}

// MARK: - Supporting Types

public extension Renderer {
    
    /// An enumeration of flags used when creating a rendering context.
    public enum Option: UInt32, BitMaskOption {
        
        /// The renderer is a software fallback.
        case software = 0x00000001
        
        /// The renderer uses hardware acceleration.
        case accelerated = 0x00000002
        
        /// Present is synchronized with the refresh rate
        case presentVsync = 0x00000004
        
        /// The renderer supports rendering to texture
        case targetTexture = 0x00000008
        
        public static let all: Set<Option> = [.software, .accelerated, .presentVsync, .targetTexture]
    }
    
    /// Information on the capabilities of a render driver or context.
    public struct Info {
        
        /// The name of the renderer.
        public let name: String
        
        /// Supported options.
        public let options: BitMaskOptionSet<Renderer.Option>
        
        /// The number of available texture formats.
        public let formats: [SDL.PixelFormat.Format]
        
        /// The maximimum texture size.
        public let maximumSize: (width: Int, height: Int)
        
        internal init(_ info: SDL_RendererInfo) {
            
            self.name = String(cString: info.name)
            self.options = BitMaskOptionSet<Renderer.Option>(rawValue: info.flags)
            self.maximumSize = (Int(info.max_texture_width), Int(info.max_texture_height))
            
            // copy formats array
            let formatsCount = Int(info.num_texture_formats)
            let formats = [info.texture_formats.0,
                           info.texture_formats.1,
                           info.texture_formats.2,
                           info.texture_formats.3,
                           info.texture_formats.4,
                           info.texture_formats.5,
                           info.texture_formats.6,
                           info.texture_formats.7,
                           info.texture_formats.8,
                           info.texture_formats.9,
                           info.texture_formats.10,
                           info.texture_formats.11,
                           info.texture_formats.12,
                           info.texture_formats.13,
                           info.texture_formats.14,
                           info.texture_formats.15]
            
            self.formats = formats.prefix(formatsCount).map { SDL.PixelFormat.Format(rawValue: $0) }
        }
    }
    
    public struct Driver {
        
        public static var all: [Driver] {
            
            let drivers = SDL.RenderDrivers()
            
            return drivers.indices.map { Driver(index: $0) }
        }
        
        public static let `default` = Driver(index: -1)
        
        public let index: Int
    }
}

public extension SDL {
    
    public struct RenderDrivers: RandomAccessCollection {
        
        public typealias Element = Renderer.Info
        public typealias Index = Int
        
        public init() { } // accesses global memory, takes no space on stack
        
        public var count: Int {
            
            return Int(SDL_GetNumRenderDrivers())
        }
        
        public subscript (index: Index) -> Element {
            
            var info = SDL_RendererInfo()
            
            guard SDL_GetRenderDriverInfo(Int32(index), &info) >= 0
                else { fatalError("Invalid index \(index)") }
            
            return Renderer.Info.init(info)
        }
        
        public subscript(bounds: Range<Index>) -> Slice<RenderDrivers> {
            return Slice<RenderDrivers>(base: self, bounds: bounds)
        }
        
        /// The start `Index`.
        public var startIndex: Index {
            return 0
        }
        
        /// The end `Index`.
        ///
        /// This is the "one-past-the-end" position, and will always be equal to the `count`.
        public var endIndex: Index {
            return count
        }
        
        public func index(before i: Index) -> Index {
            return i - 1
        }
        
        public func index(after i: Index) -> Index {
            return i + 1
        }
        
        public func makeIterator() -> IndexingIterator<RenderDrivers> {
            return IndexingIterator(_elements: self)
        }
    }
}

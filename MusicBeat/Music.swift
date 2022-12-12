//
//  File.swift
//  MusicBeat
//
//  Created by Matheus Matias on 08/11/22.
//

import Foundation
import MediaPlayer
struct Music{
    let song: MPMediaItem
    let id: MPMediaEntityPersistentID
    let songName: String
    let artist: String
    let albumArtwork: UIImage
    let genre: String
    let url: URL
    
}

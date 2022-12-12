//
//  MusicCellStructure.swift
//  MusicBeat
//
//  Created by Matheus Matias on 11/11/22.
//

import Foundation
import UIKit

class MusicCellStructure: UITableViewCell{
    
    @IBOutlet weak var ivArtwork: UIImageView!
    @IBOutlet weak var lbSongName: UILabel!
    @IBOutlet weak var lbArtist: UILabel!
    @IBOutlet weak var lbGenre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func prepare (with music: Music){
        
        ivArtwork.layer.cornerRadius = 9
        ivArtwork.image = music.albumArtwork
        lbSongName.text = music.songName
        lbArtist.text = music.artist
        lbGenre.text = music.genre
    }
}

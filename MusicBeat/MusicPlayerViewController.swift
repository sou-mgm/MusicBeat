//
//  MusicPlayerViewController.swift
//  MusicBeat
//
//  Created by Matheus Matias on 11/11/22.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol controlMusic {
    func nextMusic()
    func previousMusic()
    func playPauseSong()
}

class MusicPlayerViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet var viPlayer: UIView!
    @IBOutlet weak var ivArtwork: UIImageView!
    @IBOutlet weak var lbSongName: UILabel!
    @IBOutlet weak var lbArtistName: UILabel!
    @IBOutlet weak var btPlayPause: UIButton!
    @IBOutlet weak var btBackward: UIButton!
    @IBOutlet weak var btForward: UIButton!
    @IBOutlet weak var slMusicTime: UISlider!
    @IBOutlet weak var slMusicVolume: UISlider!
    
    
    
    var songMusic: Music! // Recebe a musica que está sendo tocada como parametro para View Player
    //Imagens do botao da View
    var delegate: controlMusic?
    let play = UIImage (systemName: "play.fill")
    let pause = UIImage (systemName: "pause.fill")
    // Default da View Player
    var viColorBackground: UIColor = .black
    var mediaPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViPlayer()
        setButtonState()
        //let  playerPlayer =  Player.init(url: songMusic.url, name: songMusic.songName)
        //playerPlayer.handleAppearing()
        //        config(with: songMusic.songName, and: songMusic.url)
    }
    
    private var player: AVPlayer?
    
    private var nowPlayingInfo = [String : Any]() {
        didSet {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }

    
    //MARK: Buttons
    
    func setButtonState() {
        
        btPlayPause.setTitle("", for: .normal)
        btBackward.setTitle("", for: .normal)
        btForward.setTitle("", for: .normal)
        
        if  mediaPlayer.playbackState == .playing{
            btPlayPause.setImage(pause, for: .normal)
            btPlayPause.setTitle("", for: .normal)
        } else {
            btPlayPause.setImage(play, for: .normal)
            btPlayPause.setTitle("", for: .normal)
        }
        
        
     
    }
    
    @IBAction func changeMusicTime(_ sender: UISlider) {
        slMusicTime.maximumValue = Float(mediaPlayer.nowPlayingItem!.playbackDuration)
        slMusicTime.value =  slMusicTime.value
        mediaPlayer.currentPlaybackTime = TimeInterval(slMusicTime.value)

    }
    
    
    @IBAction func changeMusicVolume(_ sender: UISlider) {
        
    }
    
    
    
    @IBAction func btPlayPauseSong(_ sender: UIButton) {
        delegate?.playPauseSong()
        setButtonState()
    }
    
    
    
    
    
    @IBAction func btNextSong(_ sender: UIButton) {
        delegate?.nextMusic()
        setButtonState()
        setViPlayer()
        
    }
    
    
    @IBAction func btPreviousSong(_ sender: UIButton) {
        delegate?.previousMusic()
        setButtonState()
        setViPlayer()
        
    }
}


//MARK: Extensão Set View
extension MusicPlayerViewController {
    
  
    
    //Funcao para encontra uma musica especifica, usada como parametro da View Player
    //Recebe como parametro o ID da musica, e retorna uma musica
    func findSong (findSong: MPMediaEntityPersistentID ) -> Music {
        // Cria um filtro dentre as musicas, a que possui um ID de entrada igual o ID da musica que possui no celular
        let predicate = MPMediaPropertyPredicate(value: findSong, forProperty: MPMediaItemPropertyPersistentID,comparisonType: .equalTo)
        //cria uma consulta que especifica um conjunto de itens de mídia da biblioteca de mídia do dispositivo usando um filtro e um tipo de agrupamento.
        let songQuery = MPMediaQuery()
        //add o filtro criado nesta consulta
        songQuery.addFilterPredicate(predicate)
        //Desembrulha a musica encontrada de acordo com o parametro passado. Por se tratar de um ID só haverá uma música
        if let items = songQuery.items, items.count > 0 {
            let item = items[0]
            let id = item.persistentID
            let albumArtWork = item.artwork?.image(at: CGSize(width: 60, height: 60))
            let songName = item.title
            let artist = item.artist ?? ""
            let genre = item.genre ?? ""
            songMusic = Music(song: item, id: id, songName: songName!, artist: artist, albumArtwork: ((albumArtWork ?? UIImage(named: "unknownAlbum"))!), genre: genre, url: item.assetURL!)
        }
        return songMusic
    }
    
    //Metodo para configurar o funcionamento da ViPlayer
    func setViPlayer(){
        findSong(findSong: mediaPlayer.nowPlayingItem?.persistentID ?? 0)
        viPlayer.backgroundColor = songMusic.albumArtwork.averageColor
        //Armazena a cor atual da view
        viColorBackground = viPlayer.backgroundColor!
        //Verifica a cor atual e alterar a cor do label dependendo da necessidade para melhorar a visualizacao das faixas
        checkViColor(colorVi: viColorBackground)
        //Da um set na Imagem do album
        ivArtwork.image = songMusic.albumArtwork
        //Da um set no nome da musica
        lbSongName.text = songMusic.songName
        //Da um set no artista
        lbArtistName.text = songMusic.artist
        
    }
    
    //metedo para verificar a cor da view
    func checkViColor (colorVi: UIColor){
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        // recebe as cores e add nas variaveis
        colorVi.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        // verifica se a cor é menor que 128/255 (Cores escuras)
        let verification = r1 < 0.50 && g1 < 0.50 && b1 < 0.50
        //chama o metedo para trocar cor do label
        changeLabelColor(with: verification)
    }
    
    func changeLabelColor(with whiteColor: Bool){
        if whiteColor {
            btPlayPause.configuration?.baseForegroundColor = .white
            btBackward.configuration?.baseForegroundColor = .white
            btForward.configuration?.baseForegroundColor = .white
            lbSongName.textColor = .white
            lbArtistName.textColor = .white
        } else {
            btPlayPause.configuration?.baseForegroundColor = .black
            btBackward.configuration?.baseForegroundColor = .black
            btForward.configuration?.baseForegroundColor = .black
            lbSongName.textColor = .black
            lbArtistName.textColor = .black
        }
    }
    
  
}


// Código em teste


//
//    func config(with name: String, and url: URL) {
//        self.nowPlayingInfo[MPMediaItemPropertyTitle] = name
//
//        let asset = AVURLAsset(url: url)
//
//        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
//            guard let self = self else { return }
//            let playerItem = AVPlayerItem(asset: asset)
//
//            let player = AVPlayer(playerItem: playerItem)
//            //player.actionAtItemEnd = .pause
//
//            self.player = player
//
//            self.addPeriodicTimeObserver()
//        }
//    }
//
//    func addPeriodicTimeObserver() {
//
//        let interval = CMTime(
//            seconds: 0.5,
//            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
//        )
//
//        let timeObserverToken =
//        player?.addPeriodicTimeObserver(
//            forInterval: interval,
//            queue: .main
//        ) {
//            [weak self] time in
//            print("Something")
//        }
//    }
//
//
//    func observeMusic(){
//        /*mediaPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1)) { (time) in
//            let percent = time.seconds / mediaPlayer.currentPlaybackTime
//            self.slMusicTime.setValue(Float(percent), animated: true)
//
//        }*/
//    }
    


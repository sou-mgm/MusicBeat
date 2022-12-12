//
//  MusicLibraryViewController.swift
//  MusicBeat
//
//  Created by Matheus Matias on 10/11/22.
//

import UIKit
import MediaPlayer

class MusicLibraryViewController: UIViewController {
    
    
    //MARK: Outlets
    @IBOutlet weak var viPlayer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btPlayPause: UIButton!
    @IBOutlet weak var btBackward: UIButton!
    @IBOutlet weak var btForward: UIButton!
    @IBOutlet weak var ivArtwork: UIImageView!
    @IBOutlet weak var lbSongName: UILabel!
    @IBOutlet weak var lbArtistName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryMusics () // Inicializa a leitura de musicas
        setButtonState()
        //Cria um gesto para a abertura do MusicPlayer
        let gesture = UITapGestureRecognizer (target: self, action: #selector(openPlayer(_:)))
        //ADD o gesto a viPlayer
        viPlayer.addGestureRecognizer(gesture)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MusicPlayerViewController
        vc.songMusic = songMusic
        vc.viColorBackground = viColorBackground
        vc.delegate = self
        
    }
    
    @objc func openPlayer(_ gesture:UITapGestureRecognizer){
        //abre a view do player
        performSegue(withIdentifier: "musicPlayerSegue", sender: self)
    }
    
    var musics: [Music] = [] // Recebe todas as musicas e suas informacoes
    var songsPlaying: [MPMediaItem] = [] //Recebe as musicas que serao tocas
    var mediaPlayer = MPMusicPlayerController.applicationMusicPlayer //Recebe a aplicacao de Player
    var songMusic: Music! // Recebe a musica que está sendo tocada como parametro para View Player
    //Imagens do botao da View
    let play = UIImage (systemName: "play.fill")
    let pause = UIImage (systemName: "pause.fill")
    // Default da View Player
    var viColorBackground: UIColor = .darkGray
    
    
    //MARK: Query Musics
    //Funcao para consultar musicas no bundle do iphone
    func queryMusics () {
        if let songs = MPMediaQuery.songs().items{
            //para cada musica, se for possivel recuperar o nome e URL, ele add na array
            for song in songs {
                if (song.title != nil), song.assetURL != nil{
                    //Nome da musica
                    let title = song.title
                    //ID
                    let id = song.persistentID
                    //Artista
                    let artist = song.artist ?? "Desconhecido"
                    // Arte do Album
                    let album = (song.artwork?.image(at: CGSize(width:600, height:600))!)
                    //Genero
                    let genre = song.genre ?? ""
                    let urlSong = song.assetURL!
                    //Instancia a musica
                    let newMusic = Music(song: song, id: id, songName: title!, artist: artist, albumArtwork: ((album ?? UIImage(named: "unknownAlbum"))!), genre:genre, url: urlSong)
                    musics.append(newMusic)
                    songsPlaying.append(song)
                }
            }
        }
    }
    
    
    //MARK: Player
    
    func addItemsColletion(with index: Int){
        
    }
    
    func setQueueListPlaying(startWith index: Int){
        addItemsColletion(with:index)
        let colletion = MPMediaItemCollection(items:songsPlaying)
        mediaPlayer.setQueue(with: colletion)
        //set da imagem do botao
        btPlayPause.setImage(pause, for: .normal)
        btPlayPause.setTitle("", for:.normal)
        mediaPlayer.nowPlayingItem = songsPlaying[index]
        mediaPlayer.play()
       
        
    }
    
    //MARK: Set View Music Player


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
        func setViPlayer(idMusic: MPMediaEntityPersistentID){
            findSong(findSong: idMusic)
            // Altera a cor de acordo com a capa do album
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
        
       
    
    
    //MARK: Buttons
    //Metodo para remover texto dos botoes da view
    func setButtonState() {
        btPlayPause.setTitle("", for: .normal)
        btBackward.setTitle("", for: .normal)
        btForward.setTitle("", for: .normal)
    }
        
    @IBAction func btPlayPauseSong(_ sender: UIButton) {
        playPauseSong()
    }
    
       
    @IBAction func btNextSong(_ sender: UIButton) {
        nextMusic()
        
    }
    
    
    @IBAction func btPreviousSong(_ sender: UIButton) {
        previousMusic()
    }
        
}
    
    //MARK: Extensão - TableView
    
    extension MusicLibraryViewController: UITableViewDataSource, UITableViewDelegate{
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return musics.count
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier:"musicCell", for: indexPath) as! MusicCellStructure
            let music = musics[indexPath.row]
            cell.prepare(with: music)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let id = musics[indexPath.row].id
            let index = indexPath.row
            setQueueListPlaying(startWith: index)
            setViPlayer(idMusic: id)
            tableView.deselectRow(at: indexPath, animated: false)
            
        }
        
    }
       
        

    
    //MARK: Extensão UIImage
    // Cria uma extensao para UIImage
    extension UIImage {
        // Variavel computada de cor
        var averageColor: UIColor? {
            // recebe e desembrulha a imagem
            guard let inputImage = CIImage(image: self) else {return nil}
            // cria uma array de 4 itens (que será usado de parametro de cor), onde todos iniciam com o valor 0.
            var bitmap = [UInt8](repeating: 0, count: 4)
            // Cria uma variavel de avaliação de contexto para renderizar resultados de processamento de imagem e realizar análise de imagem. Neste caso analisando a cor.
            let context = CIContext(options: [.workingColorSpace: kCFNull!])
            //realiza um render do contexto de cor analisado, usando os limite (bounds) passados como parametros
            //add os valores red,green,blue e alpha em Bitmap
            context.render(inputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil);
            //retorna uma cor, usando como parametro os valores add em bitmap
            return UIColor(red: CGFloat(bitmap[0])/255, green: CGFloat(bitmap[1])/255, blue: CGFloat(bitmap[2])/255, alpha: CGFloat(bitmap[3])/255)
        }
    }

//MARK: controlMusic
extension MusicLibraryViewController: controlMusic {

    
    
    
    func nextMusic(){
        mediaPlayer.skipToNextItem()
        let nextId = mediaPlayer.nowPlayingItem?.persistentID
        setViPlayer(idMusic: nextId!)
    }
    func previousMusic(){
        mediaPlayer.skipToPreviousItem()
        let previousId = mediaPlayer.nowPlayingItem?.persistentID
        setViPlayer(idMusic: previousId!)
    }
    
    func playPauseSong(){
        
       
        
        if  mediaPlayer.playbackState == .playing{
            btPlayPause.setImage(play, for: .normal)
            btPlayPause.setTitle("", for: .normal)
            mediaPlayer.pause()
            
            
        } else {
            btPlayPause.setImage(pause, for: .normal)
            btPlayPause.setTitle("", for: .normal)
            mediaPlayer.play()
          
        }
    }
    
}
    

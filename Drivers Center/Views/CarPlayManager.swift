import CarPlay
import MediaPlayer

class CarPlayManager: NSObject, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPTemplateApplicationScene?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, 
                                   didUpdateInterfaceStyle interfaceStyle: CPInterfaceStyle) {
        self.interfaceController = templateApplicationScene
        setupListTemplate()
    }
    
    func setupListTemplate() {
        let listTemplate = CPListTemplate(title: "My List", sections: [createListSection()])
        interfaceController?.setRootTemplate(listTemplate, animated: true)
    }
    
    private func createListSection() -> CPListSection {
        var items: [CPListItem] = []

        // Create a list item for the now playing song
        if let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
            let nowPlayingTitle = nowPlayingItem.title ?? "Unknown Title"
            let nowPlayingArtist = nowPlayingItem.artist ?? "Unknown Artist"
            let artwork = nowPlayingItem.artwork?.image(with: CGSize(width: 100, height: 100))
            
            let nowPlayingListItem = CPListItem(text: nowPlayingTitle, detailText: nowPlayingArtist)
            if let image = artwork {
                // Create a custom image for the item for now playing song
                nowPlayingListItem.image = CPImage(image: image)
            } else {
                // Use a placeholder image if there is no artwork
                nowPlayingListItem.image = CPImage(image: UIImage(systemName: "music.note")!)
            }
            items.append(nowPlayingListItem)
        }
        
        // Add other non-music related items here as needed
        let otherItem = CPListItem(text: "Other Item 1", detailText: "Detail 1")
        items.append(otherItem)
        
        return CPListSection(items: items)
    }
}
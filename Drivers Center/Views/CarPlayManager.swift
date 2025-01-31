import CarPlay
import MediaPlayer

class CarPlayManager: NSObject, CPSessionConfigurationDelegate {
    var carplayInterfaceController: CPInterfaceController?


    
    func setupListTemplate() {
        let listTemplate = CPListTemplate(title: "My List", sections: [createListSection()])
        carplayInterfaceController?.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    private func createListSection() -> CPListSection {
        var items: [CPListItem] = []

        // Create a list item for the now playing song
        if let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
            let nowPlayingTitle = nowPlayingItem.title ?? "Unknown Title"
            let nowPlayingArtist = nowPlayingItem.artist ?? "Unknown Artist"
            let artwork = nowPlayingItem.artwork?.image(at: CGSize(width: 100, height: 100))
            
            let nowPlayingListItem = CPListItem(text: nowPlayingTitle, detailText: nowPlayingArtist)
            if let image = artwork {
                // Use the UIImage directly for the item image
                nowPlayingListItem.setImage(image) // Assuming image it's most likely a UIImage
            } else {
                // Use a placeholder image if there is no artwork
                nowPlayingListItem.setImage(UIImage(systemName: "music.note")) // Or any other placeholder
            }
            items.append(nowPlayingListItem)
        }
        
        // Add additional non-music related items here
        let otherItem = CPListItem(text: "Other Item 1", detailText: "Detail 1")
        items.append(otherItem)
        
        return CPListSection(items: items)
    }
}

module MyModule::DigitalArtMarketplace {

    use aptos_framework::coin;
    use aptos_framework::signer;
    use aptos_framework::aptos_coin::{AptosCoin};

    struct ArtNFT has store, key {
        artist: address,
        owner: address,
        price: u64,
        royalty_percentage: u64, // Royalty percentage (e.g., 5%)
    }

    // Function to mint an artwork as an NFT
    public fun mint_art(artist: &signer, price: u64, royalty_percentage: u64) {
        let nft = ArtNFT {
            artist: signer::address_of(artist),
            owner: signer::address_of(artist),
            price,
            royalty_percentage,
        };
        move_to(artist, nft);
    }

    // Function to purchase the NFT and handle royalties
    public fun purchase_art(buyer: &signer, artist: address) acquires ArtNFT {
        let nft = borrow_global_mut<ArtNFT>(artist);

        // Ensure the NFT is not owned by the buyer
        assert!(nft.owner != signer::address_of(buyer), 1);

        // Calculate royalty and transfer the amount to the artist
        let royalty_amount = nft.price * nft.royalty_percentage / 100;
        coin::transfer<AptosCoin>(buyer, nft.artist, royalty_amount);

        // Transfer the remaining amount to the current owner
        let payment_to_owner = nft.price - royalty_amount;
        coin::transfer<AptosCoin>(buyer, nft.owner, payment_to_owner);

        // Transfer ownership of the NFT to the buyer
        nft.owner = signer::address_of(buyer);
    }
}

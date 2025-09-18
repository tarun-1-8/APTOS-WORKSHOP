module MyModule::NFTResumeBuilder {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;

    /// Struct representing a user's NFT resume with verified credentials
    struct Resume has store, key {
        owner: address,                    // Owner of the resume
        skills: vector<String>,           // List of verified skills
        credentials: vector<String>,      // List of verified credentials
        total_tokens: u64,               // Total verification tokens earned
    }

    /// Struct representing a skill/credential verification token
    struct VerificationToken has store, key {
        skill_name: String,              // Name of the skill or credential
        issuer: address,                 // Address of the issuing authority
        verified: bool,                  // Verification status
    }

    /// Function to create a new NFT resume for a user
    public fun create_resume(user: &signer) {
        let resume = Resume {
            owner: signer::address_of(user),
            skills: vector::empty<String>(),
            credentials: vector::empty<String>(),
            total_tokens: 0,
        };
        move_to(user, resume);
    }

    /// Function to add a verified skill/credential and mint verification token
    public fun add_verified_skill(
        user: &signer, 
        issuer: &signer, 
        skill_name: String
    ) acquires Resume {
        let user_addr = signer::address_of(user);
        let issuer_addr = signer::address_of(issuer);
        
        // Create verification token
        let token = VerificationToken {
            skill_name: skill_name,
            issuer: issuer_addr,
            verified: true,
        };
        
        // Update user's resume
        let resume = borrow_global_mut<Resume>(user_addr);
        vector::push_back(&mut resume.skills, skill_name);
        resume.total_tokens = resume.total_tokens + 1;
        
        // Store verification token with user
        move_to(user, token);
    }
}
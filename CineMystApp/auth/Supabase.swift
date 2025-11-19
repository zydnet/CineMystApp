//
//  Supabase.swift
//  CineMystApp
//
//  Created by user@50 on 19/11/25.
//

// Supabase.swift
import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.urlString)!,
    supabaseKey: SupabaseConfig.apiKey
)

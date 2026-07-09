//
//  VideosView.swift
//  ProFootball
//
//  Created by Soli Nagosa on 07/05/2026.
//

import SwiftUI
import AVKit

struct VideosView: View {
    @State private var videos: [VideoFile] = []
    @State private var selectedVideo: VideoFile?

    var body: some View {
        NavigationView {
            VStack {
                if videos.isEmpty {
                    ContentUnavailableView(
                        "אין סרטונים עדיין",
                        systemImage: "video.slash",
                        description: Text("צור סרטון במסך העריכה כדי לראות אותו כאן")
                    )
                } else {
                    List {
                        ForEach(videos) { video in
                            HStack {
                                VideoThumbnailView(url: video.url)
                                VStack(alignment: .leading) {
                                    Text(video.name)
                                        .font(.headline)
                                    Text(video.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { selectedVideo = video }
                        }
                        .onDelete(perform: deleteVideos)
                    }
                    .toolbar {
                        EditButton()
                    }
                }
            }
            .navigationTitle("הסרטונים שלי")
            .onAppear(perform: loadVideos)
            .fullScreenCover(item: $selectedVideo) { video in
                NativeVideoPlayer(url: video.url, isPresented: Binding(
                    get: { selectedVideo != nil },
                    set: { if !$0 { selectedVideo = nil } }
                ))
                .ignoresSafeArea()
            }
        }
    }

    func loadVideos() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: [.creationDateKey]
            )
            self.videos = fileURLs
                .filter { $0.pathExtension == "mp4" }
                .map { url in
                    let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                    let date = attributes?[.creationDate] as? Date ?? Date()
                    return VideoFile(url: url, name: url.lastPathComponent, date: date)
                }
                .sorted(by: { $0.date > $1.date })
        } catch {
            print("Error loading videos: \(error)")
        }
    }

    func deleteVideos(at offsets: IndexSet) {
        let fileManager = FileManager.default
        for index in offsets {
            let video = videos[index]
            try? fileManager.removeItem(at: video.url)
        }
        videos.remove(atOffsets: offsets)
    }
    // הוסף struct חדש לתצוגה מקדימה של הסרטון
    struct VideoThumbnailView: View {
        let url: URL
        @State private var thumbnail: UIImage?

        var body: some View {
            ZStack {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 44)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.7)
                        )
                }

                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                    .shadow(radius: 2)
            }
            .onAppear(perform: generateThumbnail)
        }

        func generateThumbnail() {
            Task.detached(priority: .background) {
                let asset = AVURLAsset(url: url)
                
                // חכה שה-asset יטען את ה-tracks
                guard (try? await asset.load(.tracks)) != nil else { return }
                
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: 120, height: 88)
                generator.requestedTimeToleranceBefore = .zero
                generator.requestedTimeToleranceAfter = CMTime(seconds: 1, preferredTimescale: 600)
                
                let time = CMTime(seconds: 0, preferredTimescale: 600)
                
                do {
                    let (cgImage, _) = try await generator.image(at: time)
                    let image = UIImage(cgImage: cgImage)
                    await MainActor.run { thumbnail = image }
                } catch {
                    print("Thumbnail error: \(error)")
                }
            }
        }
    }
}

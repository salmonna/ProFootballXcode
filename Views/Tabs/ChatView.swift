//
//  ChatView.swift
//  ProFootball
//

import SwiftUI

struct ChatView: View {

    @StateObject private var vm = ChatViewModel()

    var body: some View {

        NavigationStack {

            ZStack {

                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // Header
                    HStack {

                        Text("Chat")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        Button {
                            vm.messages.removeAll()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()

                    Divider()
                        .background(Color.gray)

                    // Messages
                    ScrollViewReader { proxy in

                        ScrollView {

                            LazyVStack(spacing: 12) {

                                ForEach(vm.messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onTapGesture {
                            hideKeyboard()
                        }
                        .onChange(of: vm.messages.count) {
                            if let last = vm.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id)
                                }
                            }
                        }
                    }

                    // Input
                    HStack(spacing: 12) {

                        TextField(
                            "Type message...",
                            text: $vm.inputText,
                            axis: .vertical
                        )
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .lineLimit(1...4)

                        Button {
                            vm.sendMessage()
                            hideKeyboard()
                        } label: {
                            if vm.loading {
                                ProgressView()
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ChatView()
}

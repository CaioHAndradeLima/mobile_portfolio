
import SwiftUI
import Foundation
import CachedAsyncImage

struct ContentView: View {
    @ObservedObject var viewModel = MoviesViewModel()
    @State var showingDetail = false
    @State var movieSelected: MovieItem?
    @Namespace var namespace
    
    var body: some View {
        NavigationView {
            ZStack {
                if(showingDetail && movieSelected != nil) {
                    MovieDetailItem(movieSelected: movieSelected!, namespace: namespace, showingDetail: $showingDetail)
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading movies...").onAppear {
                        viewModel.fetchMovies()
                    }
                } else if viewModel.isError {
                    VStack {
                        Text("Network Error.").padding(.bottom, 16)
                        Button("Try Again") {
                            viewModel.fetchMovies()
                        }
                    }
                } else {
                    List(viewModel.movies ?? []) { movie in
                        HStack {
                            VStack {
                                
                                if(!(showingDetail && movieSelected != nil)) {
                                    
                                    CachedAsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movie.poster_path)) { phase in
                                        switch phase {
                                        case .empty:
                                             ZStack {
                                                 ProgressView()
                                             }
                                        case .success: phase.image?
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 120, height: 120 * 1.36)
                                            
                                            
                                        default: ProgressView()
                                        }
                                        
                                    }.matchedGeometryEffect(id: movie.poster_path, in: namespace)
                                }
                            }.frame(width: 120)
                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .font(.headline)
                                Text(movie.overview)
                                    .font(.subheadline)
                                    .lineLimit(7)
                            }
                        }.onTapGesture {
                            withAnimation {
                                movieSelected = movie
                                showingDetail.toggle()
                            }
                        }
                    }.opacity(showingDetail ? 0 : 1)
                        .navigationTitle("movies")
                        .navigationBarHidden(showingDetail)
                }
                
            }
        }
    }
    
}



struct MovieDetailItem: View {
    var movieSelected : MovieItem
    var namespace: Namespace.ID
    @Binding var showingDetail: Bool
    @State private var isNavigationBarHidden = true
        
    let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .clear, location: 0.8),
            .init(color: .gray, location: 0.90),

        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    


    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        CachedAsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movieSelected.poster_path)) { phase in
                            switch phase {
                            case .success:
                                ZStack {
                                    phase.image?
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.width * 1.1)
                                        .overlay(
                                            ZStack(alignment: .bottom) {
                                                CachedAsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movieSelected.poster_path)) { phase in
                                                    if(phase.image != nil) {
                                                        phase.image!
                                                            .aspectRatio(contentMode: .fill)
                                                            .blur(radius: 20)
                                                            .mask(gradient)
                                                            .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.width * 1.1)

                                                    }
                                                }
                                            }
                                        )


                                }
                                .frame(height: UIScreen.main.bounds.width * 1.1)
                            default:
                                ProgressView()
                            }
                        }.matchedGeometryEffect(id: movieSelected.poster_path, in: namespace)
                    }
                    
                    ZStack(alignment: .topLeading) {
                            
                            CachedAsyncImage(url: URL(string: "http://image.tmdb.org/t/p/w500" + movieSelected.poster_path)) { phase in
                                if(phase.image != nil) {
                                    phase.image!
                                        .aspectRatio(contentMode: .fill)
                                        .blur(radius: 20)
                                        .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height * 0.8)
                                    
                                }
                            }

                            RoundedRectangle(cornerRadius: 0)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.8)
                                    .foregroundStyle(.ultraThinMaterial)
                                    .opacity(0.75)

                        
                        VStack(alignment: .leading) {
                            Text(movieSelected.title)
                                .font(.title)
                                .padding(.bottom, 5)

                            Text(movieSelected.overview)
                                .font(.subheadline)
                        }
                        .padding(20)
                    }
                    .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height * 0.5)

                }
            }
            
            .navigationBarTitle(movieSelected.title)
            .background(NavigationConfigurator { nc in
                nc.setNavigationBarHidden(isNavigationBarHidden, animated: true)
            })
            .navigationBarItems(leading: Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isNavigationBarHidden = false
                    showingDetail.toggle()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title).imageScale(.small)
            })
        }
        
    }
}
struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
}



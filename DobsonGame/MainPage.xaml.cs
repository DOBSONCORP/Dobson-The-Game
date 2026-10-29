using System;
using Windows.UI.Core;
using Windows.UI.ViewManagement;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Navigation;

namespace DobsonGame
{
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            this.InitializeComponent();
            this.Loaded += MainPage_Loaded;
            GameView.NavigationCompleted += GameView_NavigationCompleted;
            GameView.NewWindowRequested += GameView_NewWindowRequested;
            // Xbox: B is the system Back button. Swallow the system-level Back
            // request so pressing B never kicks the player to the Xbox menu;
            // the game itself reads the controller through the Gamepad API.
            SystemNavigationManager.GetForCurrentView().BackRequested += (s, e) => { e.Handled = true; };
        }

        private void MainPage_Loaded(object sender, RoutedEventArgs e)
        {
            // The game is a single local file, fully offline: all sprites,
            // backgrounds and music are embedded in the HTML.
            GameView.Settings.IsJavaScriptEnabled = true;
            GameView.Navigate(new Uri("ms-appx-web:///Assets/game/index.html"));
        }

        private void GameView_NavigationCompleted(WebView sender, WebViewNavigationCompletedEventArgs args)
        {
            if (!args.IsSuccess)
            {
                return;
            }
            // Give the WebView keyboard/gamepad focus so the game's own
            // Gamepad API polling (and keyboard controls) receive input.
            GameView.Focus(FocusState.Programmatic);
            ApplicationView.GetForCurrentView().TryEnterFullScreenMode();
        }

        private void GameView_NewWindowRequested(WebView sender, WebViewNewWindowRequestedEventArgs e)
        {
            // The game never opens popups; keep the player in the game.
            e.Handled = true;
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            // Xbox: keep the system UI out of the way.
            SystemNavigationManager.GetForCurrentView().AppViewBackButtonVisibility =
                AppViewBackButtonVisibility.Collapsed;
        }
    }
}

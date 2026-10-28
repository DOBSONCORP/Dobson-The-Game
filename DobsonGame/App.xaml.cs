using System;
using Windows.ApplicationModel;
using Windows.ApplicationModel.Activation;
using Windows.UI.ViewManagement;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

namespace DobsonGame
{
    sealed partial class App : Application
    {
        public App()
        {
            this.InitializeComponent();
            this.Suspending += OnSuspending;
        }

        protected override void OnLaunched(LaunchActivatedEventArgs e)
        {
            // Xbox: launch straight into fullscreen, no window chrome.
            ApplicationView.PreferredLaunchWindowingMode = ApplicationViewWindowingMode.FullScreen;
            MainPage page = Window.Current.Content as MainPage;
            if (page == null)
            {
                page = new MainPage();
                Window.Current.Content = page;
            }
            if (e.PrelaunchActivated == false)
            {
                Window.Current.Activate();
                ApplicationView.GetForCurrentView().TryEnterFullScreenMode();
            }
        }

        private void OnSuspending(object sender, SuspendingEventArgs e)
        {
            // Game state (high scores, unlocks, audio settings) lives in the
            // WebView's localStorage, which the system persists for the app.
            // Nothing extra to save here.
            var deferral = e.SuspendingOperation.GetDeferral();
            deferral.Complete();
        }
    }
}

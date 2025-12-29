local ToS_GUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/Snxdfer/Universal/refs/heads/main/Utility/ToS-System/ui.lua'))()

ToS_GUI:Agreement({
	Title = "Do you agree to this scripts ToS?",
	AgreementText = "You can put the text here that you want to your users to agree to. For example, an agreement to send analytic data, or something else like accepting the risks of the script if its ultra detected",
    OnAgreed = function() end -- Completely optional, you can remove this if you want to
})

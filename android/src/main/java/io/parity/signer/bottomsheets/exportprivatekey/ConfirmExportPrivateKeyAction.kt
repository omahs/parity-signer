package io.parity.signer.bottomsheets.exportprivatekey

import android.content.res.Configuration
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Icon
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import io.parity.signer.R
import io.parity.signer.components2.base.PrimaryButtonBottomSheet
import io.parity.signer.components2.base.SecondaryButtonBottomSheet
import io.parity.signer.models.EmptyNavigator
import io.parity.signer.models.LocalNavRequest
import io.parity.signer.models.Navigator
import io.parity.signer.ui.theme.SignerNewTheme
import io.parity.signer.ui.theme.TypefaceNew
import io.parity.signer.ui.theme.textSecondary

@Composable
fun ConfirmExportPrivateKeyAction(
	navigator: Navigator,
	publicKey: String,
) {
	val sidePadding = 24.dp
	Column(
		modifier = Modifier
			.fillMaxWidth()
			.padding(start = sidePadding, end = sidePadding),
		horizontalAlignment = Alignment.CenterHorizontally,
	) {
		Icon(
			painterResource(R.drawable.private_key_64),
			null,
			Modifier.padding(vertical = 32.dp),
			tint = MaterialTheme.colors.primary,
		)
		Text(
			text = stringResource(R.string.export_private_key_confirm_title),
			color = MaterialTheme.colors.primary,
			style = TypefaceNew.TitleL,
		)
		Text(
			modifier = Modifier.padding(top = 16.dp, bottom = 24.dp),
			text = stringResource(R.string.export_private_key_confirm_text),
			color = MaterialTheme.colors.textSecondary,
			style = TypefaceNew.BodyL,
			textAlign = TextAlign.Center,
		)

		PrimaryButtonBottomSheet(stringResource(R.string.export_private_key_confirm_title)) {
			navigator.navigate(LocalNavRequest.ShowExportPrivateKey(publicKey))
		}

		Spacer(modifier = Modifier.padding(bottom = 8.dp))

		SecondaryButtonBottomSheet(stringResource(R.string.generic_cancel)) {
			navigator.backAction()
		}
		Spacer(modifier = Modifier.padding(bottom = 24.dp))
	}
}


@Preview(
	name = "light", group = "themes", uiMode = Configuration.UI_MODE_NIGHT_NO,
	showBackground = true, backgroundColor = 0xFFFFFFFF,
)
@Preview(
	name = "dark", group = "themes",
	uiMode = Configuration.UI_MODE_NIGHT_YES,
	showBackground = true, backgroundColor = 0xFF000000,
)
@Composable
private fun PreviewConfirmExportPrivateKeyAction() {
	SignerNewTheme {
		ConfirmExportPrivateKeyAction(
			EmptyNavigator(),
			"pubkey"
		)
	}
}

#include "MediaViewerPCH.h"
#include "Cursor.h"


//!
//! Default constructor
//!
Cursor::Cursor(QObject * parent)
	: QObject(parent)
	, m_Hidden(false)
{
}

//!
//! Check the hidden state of the cursor
//!
bool Cursor::IsHidden(void) const
{
	return m_Hidden;
}

//!
//! Set the hidden state of the cursor
//!
void Cursor::SetHidden(bool hidden)
{
	if (m_Hidden != hidden)
	{
		m_Hidden = hidden;
		if (m_Hidden == true)
		{
			QGuiApplication::setOverrideCursor(QCursor(Qt::BlankCursor));
		}
		else
		{
			QGuiApplication::restoreOverrideCursor();
		}
		emit hiddenChanged(m_Hidden);
	}
}
